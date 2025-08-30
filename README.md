# 🎯 Frontend Website – Kubernetes Deployment

This project is a ReactJS website built with Node.js and deployed to AWS EKS using Jenkins, Docker, and Helm. 
It also supports running locally for development and testing.


## 🛠️ Technologies

- React.js
- Docker
- Kubernetes (EKS)
- Helm

---

## 🏗️ Project Structure

```
├── learn-website/ # Helm chart for Kubernetes deployment
├── public/ 
├── src/ 
├── Dockerfile # Docker container definition
├── package.json
└── README.md
```


---

## ⚙️ Configuration

The application requires these environment variables (in Kubernetes, provided via ConfigMaps):

| Variable                       | Description                          |
|--------------------------------|--------------------------------------|
| `REACT_APP_API_BASE_URL`       | Backend Application API end point    |


## 🐳 Docker

### 1️⃣ Build the Docker Image

To build and run locally:

```
docker build -t jidendir-b10/learn-website:latest .
```

### 2️⃣ Tag Image for ECR

```
docker tag jidendir-b10/learn-website:latest 975050024946.dkr.ecr.ap-south-1.amazonaws.com/jidendir-b10/learn-website:latest
```

### 3️⃣ Push Image to ECR

```
docker push 975050024946.dkr.ecr.ap-south-1.amazonaws.com/jidendir-b10/learn-website:latest
```

### 4️⃣ Run the Docker Container Locally (from ECR Image)

```
docker run -d -p 3001:3001 --name -learn \
  -e REACT_APP_API_BASE_URL="<API URL>" \
  975050024946.dkr.ecr.ap-south-1.amazonaws.com/jidendir-b10/learn-website:latest
```

### 5️⃣ Run the Docker Container Locally (from local build)

```
docker run -d -p 3001:3001 --name website-learn \
  -e ATLAS_URREACT_APP_API_BASE_URLI="http://localhost:3001" \
  jidendirpy/learnapi:1.0
```


## ☸️ Kubernetes Deployment (AWS EKS)

### Prerequisites

 - AWS CLI configured (aws configure)
 - `kubectl installed and configured for your EKS cluster
 - Helm installed
 - An ECR repository for your Docker images
 - Jenkins server (with access credentials)


### 1️⃣ Create Helm Chart

`helm create learn-website`

### 2️⃣ Install via Custom Values

```
helm upgrade --install learn-website ./learn-website \
-f ./learn-website/values.yaml \
--set-string image.repository=${ECR_REPO} \
--set-string image.tag=${IMAGE_TAG} \
--set service.port=80 \
--set service.targetPort=3000 \
--set-string service.type="LoadBalancer" \
--set-string api_endpoint=${API_ENDPOINT} \
--set replicaCount=3 \
--kubeconfig \$KUBECONFIG
```

### 3️⃣ Port Forwarding (For Local Access)

`kubectl port-forward service/learn-website-service 3000:3000 -n lp`

## ☁️ AWS EKS Cluster Setup

### 1️⃣ Create EKS Cluster

```
eksctl create cluster \
  --name jide-cluster-1 \
  --region ap-south-1 \
  --node-type t2.medium \
  --zones ap-south-1a,ap-south-1b
```

### 2️⃣ Update Local Kubeconfig

`aws eks update-kubeconfig --region ap-south-1 --name jide-cluster-1`


### 2️⃣ Update Local Kubeconfig

```
kubectl config use-context arn:aws:eks:ap-south-1:<account_id>:cluster/jide-cluster-1
```

#### Output EKS Cluster - Listing Pods, SVC, Helm

<img width="2352" height="643" alt="pic-1" src="https://github.com/user-attachments/assets/0f96b674-94df-4f84-a86a-19bdf848e313" />

#### Output EKS Cluster - Helm Deployment history

<img width="1850" height="160" alt="Pic-2" src="https://github.com/user-attachments/assets/45ada88d-e8c7-4d5e-aff8-02d431a2cefc" />


## ⚙️ Jenkins Configuration for Kubectl

### Install kubectl on Jenkins nodes:

```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin

kubectl version --client
```

## Jenkins Pipeline Overview

A Jenkins pipeline automates:

1. **Checkout Code**
2. **Build Docker Image**
3. **Push Image to AWS ECR**
4. **Clean up Local Docker Images**
5. **Deploy to AWS EKS using Helm**

### ⚠️ Prerequisites

Before running the pipeline:
 
- Jenkins node has Docker installed and running.
- Jenkins node has kubectl and helm installed.
- Jenkins has these credentials configured:
  - jidendiran-github-access (GitHub access token)
  - jidendiran-access-key-id (AWS Access Key)
  - jidendiran-secret-access-key (AWS Secret Key)


#### Output - Jenkin Build and Push Success to ECR with build number

<img width="2352" height="852" alt="Pic-3" src="https://github.com/user-attachments/assets/fd323155-40ad-4a76-8b0c-298441218f32" />

#### Output - Jenkin Pipeline Success

<img width="2350" height="1345" alt="Pic-4" src="https://github.com/user-attachments/assets/274e952c-0608-4a45-aab4-21d65be26d2e" />


## 📝 Important Notes and Outputs

### ✅ Helm Service Type:

The deployment uses:

`type: LoadBalancer`

This creates an **AWS ELB** exposing the API publicly.

#### Output - AWS Load balancer

<img width="2352" height="647" alt="Pic-5" src="https://github.com/user-attachments/assets/431cf4d5-f9d4-4803-b8d5-afc4a187ff0c" />


### ✅ Service Port Configuration:

 - Service Port: 80
 - Target Port: 3000


### ✅ API Endpoint to be fetched from Env variable

On the original repo code, the api end point was referenced inside the code as `http://localhost:3001`. This will not work on the live server but will work on the minikube, hence I have changed the enpoint to take the value from the environment variable. The example below

**Previous Endpoint**
```
const endpoint = `http://localhost:3001/student/getstudent`
```

**Revised Endpoint**

```
const endpoint = `${process.env.REACT_APP_API_BASE_URL}/student/getstudent`
```

The above should be changed inside all the places of the react app

### 🌐 Accessing the Website

After deployment:

1. Run: `kubectl get svc -n lp`
2. Copy the `DNS` name.
3. Test with curl: `curl http://<load-balancer-dns>/`

#### Output - Website  working in Loadbalancer DNS end point

<img width="2343" height="1099" alt="Pic-6" src="https://github.com/user-attachments/assets/0da24d46-97ea-4060-b9c7-c80c8f5617c3" />

#### Output - Website working in Custom end point after pointing the DNS CNAME on the domain 

**Login page**
<img width="2352" height="1289" alt="Pic-7" src="https://github.com/user-attachments/assets/0b0af673-8c45-4c4a-998e-2cceefc9ba36" />

**Dashboard page**
<img width="2334" height="1098" alt="Pic-8" src="https://github.com/user-attachments/assets/478ca9c8-828d-45fa-983f-a4e4d222ee51" />

**Users page**
<img width="2352" height="1281" alt="Pic-9" src="https://github.com/user-attachments/assets/07a2c79a-4b79-4779-87fa-c34a0d7f651f" />


### ✨ SSL Mapping (Optional)

- SSL is optional. You can attach an ACM certificate by adding annotations in your Service manifest.

### 🔧 Debugging Commands:

- `kubectl get pods -n lp` (list pods)
- `kubectl describe pod <pod-name> -n lp` (describe pod)
- `kubectl logs <pod-name> -n lp` (view logs)
- `kubectl logs -f <pod-name> -n lp` (follow logs)
- `kubectl exec -it <pod-name> -n lp -- /bin/bash` (shell into pod, or use /bin/sh)
- `kubectl get svc -n lp` (list services)
- `kubectl describe svc learn-api-service -n lp` (describe service)
- `kubectl get deployments -n lp` (list deployments)
- `kubectl describe deployment learn-api -n lp` (describe deployment)
- `kubectl port-forward service/learn-api-service 3001:3001 -n lp` (port forward in localhost)
- `curl localhost:3001` (test app inside pod)
- `helm list -n lp` (list Helm releases)
- `helm get values learn-api -n lp` (Helm values)
- `helm history <chart-name>` (get the history of helm deployments)
- `helm get manifest learn-api -n lp` (Helm manifest)
- `kubectl config get-contexts` (check contexts)
- `kubectl config current-context` (current context)
