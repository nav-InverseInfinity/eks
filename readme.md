
# To update -kubeconfig
- Install latest version of **awscli** - currently its > 2.0
```sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```
- Configure AWS cli and choose `yaml` as output version

```sh
aws configure set region <your-region>
aws configure --profile <profilename>
```
- Install `kubectl` [guide](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- Install/upgrade kubeconfig 
```sh
aws eks update-kubeconfig --region region-code --name my-cluster

```


