# AWS Macie Data Loss Prevention (DLP) Project

## Overview
This project implements a **Data Loss Prevention (DLP) solution** using **AWS Macie** to automatically detect and classify sensitive data within **Amazon S3 buckets**. It integrates **AWS EventBridge, SNS, and Lambda** to trigger alerts and take automated actions when sensitive data is found.

## Features
✅ **Automated Sensitive Data Scanning** – AWS Macie scans S3 for PII, financial, and other sensitive data.
✅ **Real-time Alerts** – When sensitive data is detected, notifications are sent via **Amazon SNS**.
✅ **Automated Remediation** – A Lambda function **moves sensitive files to a quarantine S3 bucket and deletes them from the original location**.
✅ **Infrastructure as Code** – Entire solution is provisioned using **Terraform**.

## Architecture Diagram
![AWS Macie DLP Architecture](your-diagram-link-here)

## AWS Services Used
- **AWS Macie** – Detects and classifies sensitive data.
- **Amazon S3** – Stores the data that is scanned by Macie.
- **AWS EventBridge** – Captures Macie findings and triggers automation.
- **AWS Lambda** – Moves flagged files to a quarantine bucket and deletes them.
- **Amazon SNS** – Sends notifications to security teams.
- **AWS IAM** – Manages permissions for Macie, Lambda, and other services.

## Setup & Deployment
### **Prerequisites**
- AWS CLI installed and configured
- Terraform installed
- AWS account with necessary permissions

### **Deployment Steps**
1. **Clone the repository:**
   ```sh
   git clone https://github.com/obinnanick/aws-macie-dlp.git
   cd aws-macie-dlp
   ```
2. **Initialize Terraform:**
   ```sh
   terraform init
   ```
3. **Plan the deployment:**
   ```sh
   terraform plan
   ```
4. **Apply the Terraform configuration:**
   ```sh
   terraform apply -auto-approve
   ```

### **How It Works**
1. **Macie scans the S3 bucket** for sensitive data (credit cards, BVNs, etc.).
2. **Findings are sent to EventBridge**, which triggers two actions:
   - Sends an alert via SNS.
   - Invokes a **Lambda function that moves the flagged file to a quarantine S3 bucket and deletes it from the original bucket**.
3. **Security teams receive real-time notifications**, confirming the quarantine and deletion.

## Project Files
- `main.tf` – Defines AWS infrastructure (S3, Macie, EventBridge, SNS, Lambda, IAM Policy)
- `macie_enable.tf` - Enabling macie before initializing the job
- `lambda_function.py` – The Python script for Lambda automation, moving sensitive files to quarantine before deletion.

## Author
👤 **Nick-Abugu Obinna**  
📧 Email: nickabuguobinna@gmail.com  
🔗 [GitHub](https://github.com/obinnanick)

## License
This project is open-source and available under the [MIT License](LICENSE).
