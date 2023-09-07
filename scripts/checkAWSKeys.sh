AWS_KEYS_PATH="${PROJECT_DIR}/../Core/Core/Assets.xcassets/Secrets/"
if [ ! -f "$AWS_KEYS_PATH/awsAccessKey.dataset/awsAccessKey" ]; then
echo "error: AWS keys are not present. Run in Terminal: yarn build-secrets \"awsAccessKey=access_key\" \"awsSecretKey=secret_key\""
exit 1
fi

if [ ! -f "$AWS_KEYS_PATH/awsSecretKey.dataset/awsSecretKey" ]; then
echo "error: AWS keys are not present. Run in Terminal: yarn build-secrets \"awsAccessKey=access_key\" \"awsSecretKey=secret_key\""
exit 1
fi

if [ ! -f "$AWS_KEYS_PATH/appArnTemplate.dataset/appArnTemplate" ]; then
echo "error: AWS Application ARN template is not present. Run in Terminal: yarn build-secrets \"appArnTemplate=app_arn_template_here\""
exit 1
fi

if [ ! -f "$AWS_KEYS_PATH/customPushDomain.dataset/customPushDomain" ]; then
echo "error: customPushDomain is not present. Run in Terminal: yarn build-secrets \"customPushDomain=custom_push_domain_here\""
exit 1
fi

if [ ! -f "$AWS_KEYS_PATH/bugfenderKey.dataset/bugfenderKey" ]; then
echo "error: bugfenderKey is not present. Run in Terminal: yarn build-secrets \"bugfenderKey=bugfender_key_here\""
exit 1
fi
