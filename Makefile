cluster-up:
	terraform apply

helm-up:
	helmfile apply

pools-up:
	kubectl apply -f manifests/ec2-node-classes.yaml
	kubectl apply -f manifests/node-pools.yaml
