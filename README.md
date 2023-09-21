# Magic Clusters
Magic Clusters recipes for various workshops

0. Email
Create a file named `.myemail.txt` that contains your email to be used in the different configuration files.

1. Init
```bash
terraform init
```

2. Edit `main.tf` and `config.yaml`

3. Plan and Apply
```bash
terraform apply -auto-approve
```

4. Destroy
```bash
terraform destroy -auto-approve -refresh=false
```
