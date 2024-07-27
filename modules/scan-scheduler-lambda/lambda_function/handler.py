from os import environ
from os.path import dirname, join
import boto3
from jinja2 import Environment, FileSystemLoader, Template

AWS_AMI_ID = environ.get("AWS_AMI_ID")
INSTANCE_TYPE = environ.get("INSTANCE_TYPE")
INSTANCE_TAG_NAME = environ.get("INSTANCE_TAG_NAME")
LAUNCH_TEMPLATE_NAME = environ.get("LAUNCH_TEMPLATE_NAME")
SECRET_NAME = environ.get("SECRET_NAME")
AWS_REGION = environ.get("AWS_REGION", "us-east-1")


def render_userdata(
        target_name: str,
        project_name: str,
        application_name: str,
        auth_name: str = None,
        terminate: bool = True
) -> str:
    """
    Create the EC2 userdata script that will run the NightVision scan.

    :param target_name: The name of the target to scan
    :param project_name: The name of the project to associate the scan with
    :param application_name: The name of the application to associate the scan with
    :param auth_name: The name of the authentication to use, if any
    :param terminate: Whether to terminate the instance after the scan
    :return:
    """
    template_dir = join(dirname(__file__))
    env = Environment(loader=FileSystemLoader(template_dir))
    template = env.get_template("userdata.sh.j2")
    scan_command = [
        "nightvision",
        "scan",
        "--target",
        target_name,
        "--project",
        project_name,
        "--app",
        application_name,
    ]
    if auth_name:
        scan_command.extend(["--auth-name", auth_name])
    userdata = template.render(
        secret_name=SECRET_NAME,
        scan_command=" ".join(scan_command),
        region=AWS_REGION,
        terminate=terminate
    )
    return userdata


def launch_ec2_from_template(
        ec2_client: boto3.Session.client,
        subnet_id: str,
        security_group_id: str,
        userdata: str,
        instance_tag_name: str,
) -> str:
    response = ec2_client.run_instances(
        ImageId=AWS_AMI_ID,
        InstanceType=INSTANCE_TYPE,
        MaxCount=1,
        MinCount=1,
        UserData=userdata,
        SecurityGroupIds=[security_group_id],
        LaunchTemplate={
            'LaunchTemplateName': LAUNCH_TEMPLATE_NAME,
            'Version': '$Latest'
        },
        SubnetId=subnet_id,
        TagSpecifications=[
            {
                "ResourceType": "instance",
                "Tags": [
                    {"Key": "Name", "Value": instance_tag_name},
                ],
            },
        ],
        MetadataOptions=dict(HttpTokens='required')

    )
    instance_id = response["Instances"][0]["InstanceId"]
    return instance_id


def lambda_handler(event, context):
    subnet_id = event['subnet_id']
    security_group_id = event['security_group_id']
    target_name = event['target']
    project_name = event['project']
    application = event['application']
    auth_name = event.get('auth_name')
    terminate = event.get('terminate')

    userdata = render_userdata(
        target_name=target_name,
        project_name=project_name,
        application_name=application,
        auth_name=auth_name,
        terminate=terminate
    )
    ec2_client = boto3.client('ec2')

    instance_id = launch_ec2_from_template(
        ec2_client=ec2_client,
        subnet_id=subnet_id,
        security_group_id=security_group_id,
        userdata=userdata,
        instance_tag_name=INSTANCE_TAG_NAME
    )
    message = "Launched instance with ID: {}".format(instance_id)
    return {
        'statusCode': 200,
        'body': {
            'message': message,
            'instance_id': instance_id
        }
    }

