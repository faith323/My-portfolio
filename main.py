import subprocess
import sys
import os
import json


if not os.path.exists("main_logs"):
    os.mkdir("main_logs")
logs_folder = "main_logs"

with open("config.json", "r") as config_file:
    variables = json.load(config_file)

domain_name = variables["domain_aliases"]


# Initialize Terraform
print("-----Initializing Terraform")
with open(f"{logs_folder}/tf_init_stdout.log", "w") as out_file, open(f"{logs_folder}/tf_init_stderr.log", "w") as err_file:
    tf_init = subprocess.run(
        ["terraform", "init"],
        cwd = "deployment/infrastructure",
        stdout = out_file,
        stderr = err_file,
        text = True,
    )
if tf_init.returncode == 0:
    print("-----Terraform initialized successfully!")
else:
    print("--!--Error occured while initializing Terraform. Check tf_init_stderr.log for details.")
    sys.exit(1)


# Apply the Terraform configuration to create the ACM certificate first
print("-----Applying Terraform configuration to ACM certificate first")
with open(f"{logs_folder}/cert_request_out.log", "w") as out_file, open(f"{logs_folder}/cert_request_err.log", "w") as err_file:
    cert_request = subprocess.run(
        ["terraform", "apply", "-target=module.acm", "-auto-approve"],
        cwd = "deployment/infrastructure",
        stdout = out_file,
        stderr = err_file,
        text = True,
    )
if cert_request.returncode != 0:
    print("--!--Error occured while creating ACM certificate. Check cert_request_err.log for details.")
    sys.exit(1)



# Apply the Terraform configuration.
print("-----Applying Terraform configuration to create the server")
with open(f"{logs_folder}/tf_apply_stdout.log", "w") as out_file, open(f"{logs_folder}/tf_apply_stderr.log", "w") as err_file:
    tf_apply = subprocess.run(
        ["terraform", "apply", "-auto-approve"],
        cwd = "deployment/infrastructure",
        stdout = out_file,
        stderr = err_file,
        text = True,
    )
if tf_apply.returncode != 0:
    print("--!--Error occured while creating infrastructure. Check tf_apply_stderr.log for details.")
    sys.exit(1)



# Direct the terraform output to a JSON file 
with open(".variables.json", "w") as var_file:
    tf_output = subprocess.run(
        ["terraform", "output", "-json"],
        cwd = "deployment/infrastructure",
        stdout = var_file,
        text = True,
        )
if tf_output.returncode != 0:
    print("--!--Error occured while retrieving Terraform output.")
    sys.exit(1)



# Load the Terraform output from the JSON file 
with open(".variables.json", "r") as var_file:
    variables = json.load(var_file)

s3_bucket_name = variables["s3_bucket_name"]["value"]
cloudfront_distribution_id = variables["distribution_id"]["value"]



# Sync the webfiles (my-portfolio/*) to the S3 bucket
with open(f"{logs_folder}/s3_sync_std.log", "w") as std_file:
    s3_sync = subprocess.run(
        ["aws", "s3", "sync", "my-portfolio/", f"s3://{s3_bucket_name}/v1", "--delete"],
        stderr=std_file,
        stdout=std_file,
    )
if s3_sync.returncode == 0:
    print("-----moved webfiles to S3 Bucket successfully!")
else:
    print("--!--Error occured while deploying webpage. Check s3_sync_stderr.log for details.")
    sys.exit(1)



# Invalidate the CloudFront cache to ensure that the latest version of the website is served to users.
with open(f"{logs_folder}/cf_validation_std.log", "w") as std_file:
    cloudfront_invalidate = subprocess.run(
        ["aws", "cloudfront", "create-invalidation", "--distribution-id", cloudfront_distribution_id, "--paths", "/v1/*"],
    stderr = std_file,
    stdout = std_file,
    text = True
    )
if cloudfront_invalidate.returncode == 0:
    print("-----Invalidation completed successfully!")
else:
    print("--!--Error occured while invalidating CloudFront cache.")
    sys.exit(1)

print(f"-----visit www.{domain_name} to view the deployed webpage.")



       
