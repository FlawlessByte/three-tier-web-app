from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import EKS, EC2, ECR
from diagrams.aws.database import RDS, ElastiCache, DocumentDB
from diagrams.aws.network import VPC, ALB, CloudFront, Route53, VPCRouter, InternetGateway, NATGateway
from diagrams.aws.security import WAF, IAM, KMS, SecretsManager
from diagrams.aws.storage import S3
from diagrams.aws.devtools import Codebuild, Codecommit, Codepipeline
from diagrams.aws.management import Cloudwatch
from diagrams.k8s.compute import Deployment, Pod
from diagrams.onprem.monitoring import Grafana, Prometheus
from diagrams.onprem.gitops import ArgoCD
from diagrams.onprem.ci import GithubActions
from diagrams.onprem.vcs import Github

with Diagram(
    "AWS 3-Tier Application Architecture", 
    show=False, 
    direction="TB",
    graph_attr={
        "pad": "1.0",  # Padding around the diagram
        "nodesep": "1.0",  # Separation between nodes
        "ranksep": "1.5"   # Separation between ranks (horizontal/vertical clusters)
    }):
    # CDN Layer
    cloudfront = CloudFront("CloudFront CDN")
    
    dns = Route53("Route 53 (DNS)")

    # CI/CD Pipeline Cluster
    with Cluster("CI/CD Pipeline"):
        github = Github("GitHub")
        github_actions = GithubActions("GitHub Actions")
        ecr = ECR("ECR")
        argocd = ArgoCD("ArgoCD")

    # Security & Monitoring Cluster
    with Cluster("Security & Monitoring"):
        secrets = SecretsManager("Secrets Manager")
        iam = IAM("IAM")
        kms = KMS("KMS")
        cloudwatch = Cloudwatch("CloudWatch")
        prometheus = Prometheus("Prometheus - Not implemented")
        grafana = Grafana("Grafana - Not implemented")
        waf = WAF("WAF - Not implemented")
    
    # Main VPC Cluster
    with Cluster("VPC (10.0.0.0/16)"):
        igw = InternetGateway("Internet Gateway")
        eks = EKS("EKS Cluster")

        with Cluster("AZ-A (eu-west-2a)"):
            # Public Subnet in AZ-A
            with Cluster("Public Subnet (10.0.1.0/24) AZ-A"):
                alb = ALB("Application Load Balancer")
                nat_a = NATGateway("NAT Gateway")

            # Private Subnet - Application Tier in AZ-A
            with Cluster("Private Subnet - App Tier (10.0.3.0/24) AZ-A"):
                api_pods_a = Deployment("Backend API Pods")
                rds = RDS("RDS Primary")
                cache = ElastiCache("ElastiCache")
                frontend_pods_a = Deployment("Frontend Web Pods")
        
        with Cluster("AZ-B (eu-west-2b)"):
            # Public Subnet in AZ-B
            with Cluster("Public Subnet (10.0.2.0/24) AZ-B"):
                nat_b = NATGateway("NAT Gateway")

            # Private Subnet - Application Tier in AZ-B
            with Cluster("Private Subnet - App Tier (10.0.4.0/24) AZ-B"):
                api_pods_b = Deployment("Backend API Pods")
                rds_sb = RDS("RDS Standby")
                cache_rr = ElastiCache("ElastiCache Read Replica")
                frontend_pods_b = Deployment("Frontend Web Pods")
                
    # Edge Services Flow
    cloudfront >> dns
    cloudfront >> frontend_pods_a
    cloudfront >> frontend_pods_b
    alb >> dns

    waf >> alb
    waf >> cloudfront

    # Application Flow
    frontend_pods_a >> api_pods_a
    frontend_pods_b >> api_pods_b
    api_pods_a >> [rds, cache]
    api_pods_b >> [rds, cache]

    # Kubernetes Cluster Flow
    eks >> [api_pods_a, api_pods_b, frontend_pods_a, frontend_pods_b, alb]
    
    # CI/CD Pipeline Flow
    github >> github_actions >> [ecr, argocd]
    argocd >> eks
    github_actions >> cloudfront

    # Network Connections
    eks >> [nat_a, nat_b] >> igw

    # Monitoring and Security Connections
    prometheus >> eks
    grafana >> prometheus
    cloudwatch >> [eks, rds]
    secrets >> [api_pods_a, api_pods_b, frontend_pods_a, frontend_pods_b]
    iam >> eks
    kms >> rds