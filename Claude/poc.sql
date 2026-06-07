1. Download CLAUDE.md above

2. mkdir aws-ai-monitor && cd aws-ai-monitor
   → paste CLAUDE.md here

3. Get Claude API key → console.anthropic.com

4. Open Claude Code → type:
   "Read CLAUDE.md and build the complete project.
    Generate ALL files so I can run directly."

5. Set env variables:
   export AWS_ACCESS_KEY_ID=xxx
   export AWS_SECRET_ACCESS_KEY=xxx
   export AWS_REGION=ap-south-1
   export CLAUDE_API_KEY=sk-ant-xxx

6. Run backend → mvn spring-boot:run
   Run frontend → npm install && npm start

7. Open http://localhost:3000 → Click Analyze with AI 🎉

=========================================================================================
Now Here Are Your Exact Next Steps 🚀

Step 1 — Get Claude API Key (5 mins)

1. Go to → console.anthropic.com
2. Sign up → Click "API Keys" → Create Key
3. Copy key (starts with sk-ant-...)

Step 2 — Create project folder & add CLAUDE.md

mkdir aws-ai-monitor
cd aws-ai-monitor
# paste the downloaded CLAUDE.md here

Step 3 — Open Claude Code & run this command

claude
Then type inside Claude Code:

Read the CLAUDE.md file in this folder and build the 
complete project — backend (Spring Boot Java 11 Maven) 
and frontend (React CRA). Generate ALL files completely 
so I can run them directly without any changes.

Step 4 — Set your environment variables

export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
export AWS_REGION=ap-south-1
export CLAUDE_API_KEY=sk-ant-your_key

Step 5 — Run backend + frontend

# Terminal 1
cd backend && mvn spring-boot:run

# Terminal 2
cd frontend && npm install && npm start

Step 6 — Open browser

http://localhost:3000
→ See live AWS metrics
→ Click "Analyze with AI"
→ Claude gives health score + recommendations

What Your Demo Will Look Like 🎯
Dashboard loads → EC2 table + RDS table + Alarms
       ↓
Click "Analyze with AI"
       ↓
Claude returns:
  Health Score: 72/100  ⚠️ WARNING
  Risk Level: MEDIUM
  Issues: EC2 instance i-xxxx stopped unexpectedly...
  Recommendations: Restart instance or check auto-scaling...