# Nexus Repository on GKE with Terraform 🚀

This project provides a complete solution for deploying a [Sonatype Nexus Repository](https://www.sonatype.com/products/nexus-repository) on Google Kubernetes Engine (GKE) using Terraform.

The setup automates the provisioning of all necessary Google Cloud infrastructure, including:

- A GKE cluster with Workload Identity enabled.
- An Artifact Registry for storing a custom Nexus Docker image.
- A Google Cloud Storage (GCS) bucket for Nexus blobstore.
- IAM service accounts and permissions for secure access between Nexus and GCS.

The deployment uses a custom Nexus Docker image that includes the [Google Cloud Storage blobstore plugin](https://github.com/sonatype-nexus-community/nexus-blobstore-google-cloud), allowing Nexus to use GCS for artifact storage natively.

---

## Prerequisites

Before you begin, ensure you have the following tools installed and configured:

- Google Cloud SDK (`gcloud`)
- Terraform (`>= 1.0`)
- kubectl
- Docker
- A Google Cloud Project with billing enabled.

---

## Project Structure

The Terraform code is organized into modules for clarity and reusability. You can generate this structure using the provided `folder-tree.sh` script.

```sh
gcp-nexus-infra/
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
└── modules/
    ├── gke/
    ├── iam/
    ├── networking/
    └── storage/
```

---

## Deployment Steps

Follow these steps to deploy the entire stack.

---

### Step 1: Configure and Deploy Infrastructure

First, we will use Terraform to provision the GKE cluster, GCS bucket, Artifact Registry, and all necessary IAM roles.

1.  **Navigate to the Terraform directory:**
    ```bash
    cd gcp-nexus-infra
    ```

---

2.  **Create a `terraform.tfvars` file.** This file will contain your project-specific values.

    **`terraform.tfvars`**

    ```hcl
    project_id       = "your-gcp-project-id"
    region           = "us-central1"
    gke_cluster_name = "nexus-cluster"
    gcs_bucket_name  = "your-unique-nexus-bucket-name"
    # ... other variables
    ```

3.  **Initialize Terraform:**

    ```bash
    terraform init
    ```

4.  **Apply the Terraform configuration:**
    Review the plan and type `yes` when prompted.
    ```bash
    terraform apply
    ```
    This process will take several minutes. Once complete, Terraform will output important values, such as the `gcp_service_account_email`. **Take note of this email, as you will need it in a later step.**

---

### Step 2: Build and Push the Custom Docker Image

With the Artifact Registry created by Terraform, you can now build the custom Nexus image and push it.

1.  **Configure Docker to authenticate with Artifact Registry:**

    ```bash
    gcloud auth configure-docker [REGION]-docker.pkg.dev
    ```

    Replace `[REGION]` with the region you used in your Terraform variables (e.g., `us-central1`).

2.  **Build the Docker image.** Make sure you are in the root directory of the project where the `Dockerfile` is located.

    ```bash
    docker build -t [REGION]-docker.pkg.dev/[PROJECT_ID]/[REPOSITORY]/nexus-custom:latest .
    ```

    Replace `[REGION]`, `[PROJECT_ID]`, and `[REPOSITORY]` (e.g., `nexus-repo`) with your specific values.

3.  **Push the image to Artifact Registry:**
    ```bash
    docker push [REGION]-docker.pkg.dev/[PROJECT_ID]/[REPOSITORY]/nexus-custom:latest
    ```

---

### Step 3: Configure and Deploy Nexus on GKE

Now, we'll deploy the Nexus application to the GKE cluster.

1.  **Update the Kubernetes manifest:**
    Open the `nexus-k8s.yaml` file. You need to update the Google Service Account (GSA) annotation and the image path.

---

    ```yaml
    # nexus-k8s.yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: nexus-ksa
      namespace: nexus-ns
      annotations:
        # 👇 UPDATE THIS with the output from `terraform apply`
        iam.gke.io/gcp-service-account: "sa-nexus@your-project-id.iam.gserviceaccount.com"
    ---
    # ...
    spec:
      containers:
        - name: nexus
          # UPDATE THIS with your full image path
          image: us-central1-docker.pkg.dev/your-project-id/nexus-repo/nexus-custom:latest
    ```

2.  **Connect `kubectl` to your new GKE cluster:**

    ```bash
    gcloud container clusters get-credentials [GKE_CLUSTER_NAME] --region [REGION]
    ```

    Replace `[GKE_CLUSTER_NAME]` and `[REGION]` with your values.

3.  **Apply the Kubernetes manifest:**
    ```bash
    kubectl apply -f nexus-k8s.yaml
    ```

### Step 4: Access and Configure Nexus

1.  **Get the External IP Address:**
    It may take a few minutes for the Load Balancer to be provisioned. Run the following command and wait for an IP to appear under `EXTERNAL-IP`.

    ```bash
    kubectl get svc nexus-service -n nexus-ns --watch
    ```

    Once available, access Nexus at `http://<EXTERNAL-IP>:8081`.

2.  **Retrieve the Initial Admin Password:**
    The initial password is in a file inside the pod. Use this command to retrieve it:
    ```bash
    kubectl exec -n nexus-ns $(kubectl get pods -n nexus-ns -l app=nexus -o jsonpath='{.items[0].metadata.name}') -- cat /nexus-data/admin.password
    ```
    Log in with the username `admin` and this password. You will be prompted to change it.

---

3.  **Configure the GCS Blob Store:**
    - In the Nexus UI, navigate to **Administration (⚙️) > Repository > Blob Stores**.
    - Click **Create blob store** and select **Google Cloud Storage** as the `Type`.
    - Fill in the `Bucket` name. No credentials are required thanks to Workload Identity.
    - !Nexus GCS Blobstore Configuration
