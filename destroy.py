import subprocess
import sys
import os
import json
import shutil

print('-----Running this script destroys what you have created\n'
'-----in main.py, do you wish to continue?\n'
'-----Only "yes" will be accepted')

choice = input()
if choice != "yes":
    sys.exit()

if not os.path.exists("destroy_logs"):
    os.mkdir("destroy_logs")

logs_folder = "destroy_logs"


# Load the Terraform output from the JSON file to get bucket and distribution info
if os.path.exists(".variables.json"):
    with open(".variables.json", "r") as var_file:
        variables = json.load(var_file)
    
    s3_bucket_name = variables["s3_bucket_name"]["value"]
    cloudfront_distribution_id = variables["distribution_id"]["value"]
else:
    print(".variables.json not found.")
    sys.exit()



# Empty the S3 bucket before destroying infrastructure
with open(f"{logs_folder}/empty_bk_out.log", "w") as std_file:
    s3_remove = subprocess.run(
        ["aws", "s3", "rm", f"s3://{s3_bucket_name}", "--recursive"],
        cwd=".",
        text=True,
        stderr=std_file,
        stdout=std_file
    )
if s3_remove.returncode == 0:
    print("-----S3 bucket emptied successfully!")
else:
    print("--!--Warning: S3 bucket removal encountered an issue.")
    sys.exist()


# Destroy the Terraform infrastructure
print("-----Destroying Terraform infrastructure")
with open(f"{logs_folder}/tf_destroy_stdout.log", "w") as out_file, open(f"{logs_folder}/tf_destroy_stderr.log", "w") as err_file:
    tf_destroy = subprocess.run(
        ["terraform", "destroy", "-auto-approve"],
        cwd="deployment/infrastructure",
        stdout=out_file,
        stderr=err_file,
        text=True,
    )
if tf_destroy.returncode == 0:
    print("-----Infrastructure destroyed successfully!")
else:
    print("--!--Error occurred while destroying infrastructure. Check tf_destroy_stderr.log for details.")
    sys.exit(1)


# Clean up generated files
print("-----Cleaning up generated files")
if os.path.exists(".variables.json"):
    os.remove(".variables.json")
    print("-----Removed .variables.json")

print("-----completed!")
