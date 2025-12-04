# **Deploying the Jarvis Desktop Voice Assistant on AWS EC2 using Terraform and Jenkins**

This project demonstrates a complete DevOps workflow for deploying the **Jarvis Desktop Voice Assistant** application on an AWS EC2 instance using **Terraform** (Infrastructure as Code) and **Jenkins CI/CD** with GitHub Webhooks for automated deployments.

---

## **1. Project Architecture**

```
GitHub Repo  --->  Jenkins Pipeline  --->  EC2 Instance (Jarvis App)
       |                   |  
Webhook Trigger      SSH Deploy via Key  
```

---

## **2. Prerequisites**

* AWS Account
* Terraform installed
* Jenkins installed on EC2
* SSH Key Pair
* GitHub repository fork
* Basic AWS & CI/CD knowledge

---

## **3. Step 1: Fork the Repository**

Fork the original project:

```
https://github.com/kishanrajput23/Jarvis-Desktop-Voice-Assistant
```

Apply at least one UI or text update and push it to your GitHub repository.

### Screenshot Example

![Git Clone](Images/git_clone.png)

---

## **4. Step 2: Provision Infrastructure Using Terraform**

Terraform provisions:

* EC2 instance
* Security group
* Key pair
* User data to configure Jarvis
* systemd service for auto-start

### Initialize Terraform

```bash
terraform init
```
---

### Run Terraform Plan

```bash
terraform plan
```
---

### Apply Terraform

```bash
terraform apply --auto-approve
```

![Terraform Apply](Images/terraform_auto_approve.png)

---

### EC2 Instances Dashboard

![EC2 Instances](Images/servers.png)

---

## **5. Step 3: Verify Jarvis Service on EC2**

SSH into the EC2 instance and verify service status:

```bash
sudo systemctl status jarvis
```

![Jarvis Service](Images/activate_jarvis.png)

---

## **6. Step 4: Configure Jenkins**

### Add SSH Credentials

Navigate to:
**Manage Jenkins → Credentials → System → Global → Add Credentials**

* Kind: SSH Username with Private Key
* ID: `devops-key`
* Username: `ubuntu`
* Private Key: content of `check.pem`

![Jenkins Credentials](Images/jenkins_credentials.png)

---

## **7. Step 5: Create Jenkins Pipeline**

Use the following Jenkinsfile:

```groovy
pipeline {
    agent any

    environment {
        REMOTE_USER = "ubuntu"
        REMOTE_HOST = "65.2.191.170"
        REMOTE_DIR  = "/home/ubuntu/Jarvis-Desktop-Voice-Assistant"
        SERVICE_NAME = "jarvis"
        CRED_ID = "devops-key"
        SSH_OPTS = "-o StrictHostKeyChecking=no"
    }

    stages {

        stage("Checkout Code") {
            steps {
                git branch: 'main',
                    url: '(https://github.com/RajAhire-1/Jarvis-Desktop-Voice-Assistant.git)'
            }
        }

        stage("Fix Permissions on Server") {
            steps {
                sshagent (credentials: ["${CRED_ID}"]) {
                    sh """
                    ssh ${SSH_OPTS} ${REMOTE_USER}@${REMOTE_HOST} '
                        sudo mkdir -p ${REMOTE_DIR}
                        sudo chown -R ubuntu:ubuntu ${REMOTE_DIR}
                        sudo chmod -R 755 ${REMOTE_DIR}
                    '
                    """
                }
            }
        }

        stage("Deploy Code via rsync") {
            steps {
                sshagent (credentials: ["${CRED_ID}"]) {
                    sh """
                    rsync -avz -e "ssh ${SSH_OPTS}" \
                    --exclude='.git' \
                    --exclude='__pycache__' \
                    ./ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/
                    """
                }
            }
        }

        stage("Install Dependencies") {
            steps {
                sshagent (credentials: ["${CRED_ID}"]) {
                    sh """
                    ssh ${SSH_OPTS} ${REMOTE_USER}@${REMOTE_HOST} '
                        sudo apt update -y
                        sudo apt install -y python3 python3-pip ffmpeg
                        cd ${REMOTE_DIR}
                        pip3 install -r requirements.txt --break-system-packages || true
                    '
                    """
                }
            }
        }

        stage("Restart Jarvis Service") {
            steps {
                sshagent (credentials: ["${CRED_ID}"]) {
                    sh """
                    ssh ${SSH_OPTS} ${REMOTE_USER}@${REMOTE_HOST} '
                        sudo systemctl daemon-reload
                        sudo systemctl restart ${SERVICE_NAME}
                        sudo systemctl status ${SERVICE_NAME} --no-pager
                    '
                    """
                }
            }
        }
    }
}
```

---

## **8. Step 6: Configure GitHub Webhook**

Go to:
**GitHub → Repo → Settings → Webhooks → Add Webhook**

* Payload URL:

  ```
  http://<JENKINS_PUBLIC_IP>:8080/github-webhook/
  ```
* Content type: `application/json`
* Event: **Just the push event**

---

## **9. Step 7: Validate Automatic Deployment**

Push any new commit to GitHub.
Jenkins should automatically trigger and deploy the update.

![Jenkins Success](Images/jenins_deploy_success.png)

---

## **10. Conclusion**

This project demonstrates:

* Infrastructure automation using Terraform
* CI/CD automation with Jenkins
* Secure SSH deployment
* Continuous deployment using GitHub Webhooks
* Managing Python applications as systemd services

It provides a strong foundation for scalable DevOps workflows.

---

## **Screenshot Index**

| Step                      | Image                             |
| ------------------------- | --------------------------------- |
| Git Clone                 | ![](Images/git_clone.png)              |
| Terraform Init            | ![](Images/terraform_init.png)        |
| Terraform Plan            | ![](Images/terraform_plan.png )        |
| Terraform Apply           | ![](Images/terraform_auto_approve.png) |
| EC2 Instances             | ![](Images/servers.png)                |
| Jarvis Service            | ![](Images/activate_jarvis.png)        |
| Jenkins Credentials       | ![](Images/jenkins_credentials.png)    |
| Jenkins Deployment Output | ![](Images/jenins_deploy_success.png)  |
