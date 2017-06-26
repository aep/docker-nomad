.PHONY: bin image push release clean

TAG=aaep/docker-nomad
VERSION=0.5.6

0.X/pkg/nomad:
	docker run --rm -v $(shell pwd)/0.X/pkg:/tmp/pkg golang sh -c '\
	apt-get update && apt-get -y install g++-multilib && \
	go get -u github.com/hashicorp/nomad && \
	cd $$GOPATH/src/github.com/hashicorp/nomad && \
	git checkout v$(VERSION) && \
	make bootstrap && \
	make generate && \
	go build --ldflags "-extldflags \"-static\"" -o /tmp/pkg/nomad'

0.X/pkg/amazon-ecr-credential-helper:
	docker run --rm -v $(shell pwd)/0.X/pkg:/tmp/pkg golang sh -c '\
	apt-get update && apt-get -y install g++-multilib && \
	mkdir -p $$GOPATH/src/github.com/awslabs/ && \
	cd $$GOPATH/src/github.com/awslabs/ && \
	git clone https://github.com/awslabs/amazon-ecr-credential-helper.git && \
	cd amazon-ecr-credential-helper && \
	make && \
	cp bin/local/docker-credential-ecr-login /tmp/pkg/'

image: 0.X/pkg/nomad 0.X/pkg/amazon-ecr-credential-helper
	docker build --tag $(TAG):latest --tag $(TAG):$(VERSION) 0.X/

push: image
	docker push $(TAG):latest
	docker push $(TAG):$(VERSION)

release: push

clean:
	rm -rf 0.X/pkg
	docker rmi -f $(TAG)
