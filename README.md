# Torque blueprint repository for Jenkins deployment

This blueprint repository allows you to easily deploy Jenkins and connect it to your Torque account.
After deployment, this Jenkins instance can be immediately used to launch your pipelines against environments
provided by Torque. It comes with a sample pipeline, so that you will have an entry point from which
you can start modeling your CI/CD flows using Jenkins and Torque.

### This repo contains two blueprints:

#### Jenkins

This blueprint deploys a Sandbox using Jenkins. Its flow comprises the following steps:

1. Deploy Jenkins
2. Install Torque's Jenkins plugin and dependencies
3. Configure a connection between Torque and Jenkins
4. Create a sample demo pipeline 

#### Promotions Manager

A demo blueprint used by the predefined pipeline in Jenkins.
Deploys a sandbox with a sample app consisting of back end, front end, and database components.

## Usage

### Prerequisites

* Only AWS cloud provider is currently supported
* Before using this solution, you need to have an S3 bucket to store artifacts built by the sample Jenkins job
* You also need to create an IAM role (for EC2 service) that has write permissions for your S3 bucket, and configure it with write permissions to your S3 bucket

### Torque setup

#### Link your AWS account and S3 bucket to Torque

Go to **Settings** > **Cloud Accounts** and link your AWS account. Then, in the **Integrations** tab, set your S3 bucket as the artifacts repository.

#### Connect blueprint repo to your Torque space

In your space, go to **Settings** > **Blueprint Repositories** and connect this repo as the **Blueprint Repository for Sandbox Environments**.
If you want to experiment with the code and make some changes, fork it and connect your own repository.

#### Activate blueprints

Go to **Blueprints** and publish both Jenkins and Promotions Manager blueprints in the **Space Blueprints** list.

You may now start working with the Jenkins blueprint.

### Jenkins Blueprint Usage

Now you are ready to launch a sandbox with Jenkins on the **Sandbox Environment** page.

Jenkins Blueprint has the following list of input parameters:

* `AWS_INSTANCE_TYPE` - specify the AWS instance type according to the required size (default is `m5.large`).

* `JENKINS_ADMIN_PASS` - set the password you will use when logging in to Jenkins with the admin user. Default is `admin`.

* `CS_TORQUE_TOKEN` - token that Jenkins will use to communicate with Torque. You can generate it on the **Settings** > **Integrations** page.

* `IAM_ROLE` - IAM role instance profile name you previously created.

* `SPACE_NAME` - the name of the space in which Jenkins will run sandboxes. For our purposes, specify the name of your current space.

	**Note**: In the future, you might want to create your personal blueprints and configure Jenkins pipelines to use them. These blueprints will probably live in other spaces.

* `BUCKET_NAME` - name of the S3 bucket connected to the space you created for artifacts.

![params](https://user-images.githubusercontent.com/76521367/124805133-c84a4900-df63-11eb-89eb-7b0630b3d967.PNG)

### Demo pipeline

After sandbox deployment, you can log into Jenkins using **Quick Link**.

![quick_link](https://user-images.githubusercontent.com/8643801/96999652-2f42e180-153e-11eb-8bdc-4eada85136eb.png)

In Jenkins, you should see a predefined pipeline configured to run a Promotions Manager blueprint in your Torque space.

![jenkins](https://user-images.githubusercontent.com/8643801/96999412-c8bdc380-153d-11eb-96e0-3bd4be4e6816.png)

#### Pipeline steps

The default pipeline loaded with this Jenkins instance will automatically run the following steps:​

1. Retrieve latest code of the promotion app from Git​
2. Build artifact package (latest build)​
3. Upload build to S3 repository​
4. Deploy the promotions manager application to AWS in a Torque Sandbox​
5. Run tests​
6. Terminate the promotions manager application  
