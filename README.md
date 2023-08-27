# sigstore-example

Quick example of signing commits, images and attesting
- https://gist.github.com/garethahealy/45a7193172c33cd9e7a25b790421236e

## Docker

```
docker buildx build --attest=type=provenance,mode=max . -t quay.io/garethahealy/sigstore-demo --push
docker buildx imagetools inspect quay.io/garethahealy/sigstore-demo --format "{{ json .Provenance.SLSA }}" | jq . > slsa.json

cosign attest --predicate slsa.json --type slsaprovenance quay.io/garethahealy/sigstore-demo
```
