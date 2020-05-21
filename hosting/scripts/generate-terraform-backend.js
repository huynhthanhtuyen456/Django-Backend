#! /usr/bin/env node
'use strict';

const glob = require('glob');
const path = require('path');
const program = require('commander');
const { readJson, writeJson, getTerraformConfig } = require('./common');
const execSync = require('child_process').execSync;

program
  .option('--environment [config_name]', 'Environment (production or development')
  .option('--destroy [config_name]', 'Flag to destroy environment')
  .option('--at [config_name]', 'Generate config for AT part')
  .option('--db [config_name]', 'Generate config for DB part')
  .option('--ec2 [config_name]', 'Generate config for master_instance')
  .option('--iam [config_name]', 'Generate config for IAM')
  .option('--api [config_name]', 'Generate config for API')
  .option('--s3 [config_name]', 'Generate config for S3')
  .option('--elasticache [config_name]', 'Generate config for Elasticache')
  .option('--vpc [config_name]', 'Generate config for VPC')
  .option('--dynamodb [config_name]', 'Generate config for DynamoDB')
  .option('--lambda [config_name]', 'Generate config for Lambda')
  .option('--ecr [config_name]', 'Generate config for ECR')
  .option('--sns [config_name]', 'Generate config for SNS')
  .parse(process.argv);

const getBaseConfig = (config) => ({
  bucket: `${config.account_id}-${config.region}-terraform-states`,
  region: config.region,
});

(async () => {
  if (program.at) {
    const { config } = await readJson(`hosting/terraform/${program.environment}.json`);
    const backend = {
      ...getBaseConfig(config),
      key: `at/state.tfstate`,
    };
    await runTerraform('at', program, config, backend)
  }
  if (program.db) {
    const { config } = await readJson(`hosting/terraform/${program.environment}.json`);
    const backend = {
      ...getBaseConfig(config),
      key: `main_cluster/state.tfstate`,
    };
    await runTerraform('db', program, config, backend)
  }
  if (program.ec2) {
    const { config } = await readJson(`hosting/terraform/${program.environment}.json`);
    const backend = {
      ...getBaseConfig(config),
      key: `master_instance/state.tfstate`,
    };
    await runTerraform('ec2', program, config, backend)
  }
  if (program.iam) {
    const { config } = await readJson(`hosting/terraform/${program.environment}.json`);
    const backend = {
      ...getBaseConfig(config),
      key: `iam/state.tfstate`,
    };
    await runTerraform('iam', program, config, backend)
  }
  if (program.api) {
    const { config } = await readJson(`hosting/terraform/${program.environment}.json`);
    const backend = {
      ...getBaseConfig(config),
      key: `api/state.tfstate`,
    };
    await runTerraform('api', program, config, backend)
  }
  if (program.s3) {
    const { config } = await readJson(`hosting/terraform/${program.environment}.json`);
    const backend = {
      ...getBaseConfig(config),
      key: `s3/state.tfstate`,
    };
    await runTerraform('s3', program, config, backend)
  }
  if (program.elasticache) {
    const { config } = await readJson(`hosting/terraform/${program.environment}.json`);
    const backend = {
      ...getBaseConfig(config),
      key: `elasticache/state.tfstate`,
    };
    await runTerraform('elasticache', program, config, backend)
  }
  if (program.vpc) {
    const { config } = await readJson(`hosting/terraform/${program.environment}.json`);
    const backend = {
      ...getBaseConfig(config),
      key: `vpc/state.tfstate`,
    };
    await runTerraform('vpc', program, config, backend)
  }
  if (program.dynamodb) {
    const { config } = await readJson(`hosting/terraform/${program.environment}.json`);
    const backend = {
      ...getBaseConfig(config),
      key: `dynamodb/state.tfstate`,
    };
    await runTerraform('dynamodb', program, config, backend)
  }
  if (program.lambda) {
    const { config } = await readJson(`hosting/terraform/${program.environment}.json`);
    const backend = {
      ...getBaseConfig(config),
      key: `lambda/state.tfstate`,
    };
    await runTerraform('lambda', program, config, backend)
  }
  if (program.ecr) {
    const { config } = await readJson(`hosting/terraform/${program.environment}.json`);
    const backend = {
      ...getBaseConfig(config),
      key: `ecr/state.tfstate`,
    };
    await runTerraform('ecr', program, config, backend)
  }
  if (program.sns) {
    const { config } = await readJson(`hosting/terraform/${program.environment}.json`);
    const backend = {
      ...getBaseConfig(config),
      key: `sns/state.tfstate`,
    };
    await runTerraform('sns', program, config, backend)
  }})()
.then(() => {
  process.exit(0);
})
.catch(err => {
  console.error(err);
  process.exit(1);
})

const runTerraform = async (component, program, config, backend) => {
  await writeJson(`hosting/terraform/${component}/envs/${program.environment}.backend.json`, backend);
  await writeJson(`hosting/terraform/${component}/envs/${program.environment}.json`, config);
  execSync(`cp hosting/terraform/${program.environment}.json hosting/terraform/${component}/envs/${program.environment}.json`, {stdio: 'inherit'});
  execSync(`cd hosting/terraform/${component} && terraform init -backend-config=envs/${program.environment}.backend.json`, {stdio: 'inherit'});
  if (program.destroy) {
    execSync(`cd hosting/terraform/${component} && terraform destroy -var-file=envs/${program.environment}.json`, {stdio: 'inherit'});  
  } else {
    execSync(`cd hosting/terraform/${component} && terraform apply -var-file=envs/${program.environment}.json`, {stdio: 'inherit'});
  }
};
