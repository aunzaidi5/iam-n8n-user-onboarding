# IAM User Onboarding Automation with n8n

An end-to-end IAM automation lab that detects newly created Active Directory users and triggers an n8n workflow for onboarding notifications, audit logging, and AI-assisted access recommendations.

The solution integrates **Active Directory, PowerShell, n8n, Docker, Slack, Google Sheets, Gmail, and a locally hosted Ollama/Qwen2.5 model**.

> The AI component is recommendation-only and does not automatically grant Active Directory group membership.

![Complete Workflow](screenshots/01-Complete-Workflow.PNG)
