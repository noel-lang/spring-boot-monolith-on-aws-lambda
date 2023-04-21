**samconfig.toml**
```toml
version = 0.1
[default]
[default.deploy]
[default.deploy.parameters]
stack_name = "<stack-name>"
s3_bucket = "<s3-bucket-name>"
capabilities = "CAPABILITY_IAM"
template_file = ".aws-sam/build/template.yaml"
image_repository = "<ecr-repository-uri>"
region = "eu-central-1"

[default.build]
[default.build.parameters]
template = "template.yaml"
use_container = true
```
