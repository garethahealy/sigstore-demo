#!/bin/sh
#set -X
#doitlive commentecho: true
#doitlive commentecho: true
#doitlive speed: 3
#doitlive shell: /bin/zsh
# 
# Lets start off with building the image. Going to use to docker buildx as that creates us a provenance file 

docker buildx build --attest=type=provenance,mode=max . -t quay.io/garethahealy/sigstore-demo --push

# Sadly, you can only get it back from a pushed image
docker buildx imagetools inspect quay.io/garethahealy/sigstore-demo --format "{{ json .Provenance.SLSA }}" | jq . > slsa.json

# Now its in the registry, we'll work out the SHA
cosign triangulate quay.io/garethahealy/sigstore-demo:latest | sed 's/^.*sha256-//;s/.sig//' > digest.txt
cat digest.txt

# Sign the image
cosign sign --yes quay.io/garethahealy/sigstore-demo@sha256:$(cat digest.txt)

# And verify it
cosign verify --certificate-identity garethahealy@gmail.com --certificate-oidc-issuer https://github.com/login/oauth quay.io/garethahealy/sigstore-demo@sha256:$(cat digest.txt)

# And attach that provenance 
cosign attest --yes --predicate slsa.json --type slsaprovenance quay.io/garethahealy/sigstore-demo@sha256:$(cat digest.txt)

# And verify it against my identity
cosign verify-attestation --certificate-identity garethahealy@gmail.com --certificate-oidc-issuer https://github.com/login/oauth --type https://slsa.dev/provenance/v0.2 quay.io/garethahealy/sigstore-demo@sha256:$(cat digest.txt)

# Now lets see the sig and att and how they are attached to the image
cosign tree quay.io/garethahealy/sigstore-demo

# Download the attestation in DSSE format
cosign download attestation --predicate-type=https://slsa.dev/provenance/v0.2 quay.io/garethahealy/sigstore-demo@sha256:$(cat digest.txt) | jq '.'

# And see the raw payload attached
cosign download attestation --predicate-type=https://slsa.dev/provenance/v0.2 quay.io/garethahealy/sigstore-demo@sha256:$(cat digest.txt) | jq -r '.payload' | base64 -d | jq '.'