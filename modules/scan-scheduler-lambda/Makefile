SHELL:=/bin/bash

invoke:
	aws lambda invoke --function-name nightvision-scheduled-scan --cli-binary-format raw-in-base64-out --payload '{ "subnet_id": "subnet-07a080852c0769a32", "security_group_id": "sg-0839aeaccdda71f96", "target": "testphp", "project": "kinnaird", "application": "testphp" }' --log-type Tail response.json; cat response.json
with-auth:
	aws lambda invoke --function-name nightvision-scheduled-scan --cli-binary-format raw-in-base64-out --payload '{ "subnet_id": "subnet-07a080852c0769a32", "security_group_id": "relay-cluster-SecurityGroup-vMSEpDWXm7m1", "target_name": "testphp", "auth_name": "value", "project_name": "value" }' --log-type Tail response.json; cat response.json
