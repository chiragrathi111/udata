If you any branches checkout put some importtant line:-
1 git pull (all new code is coming)
2 git checkout <branches name>
3 git pull
4 git branches (Check your branches name)


change git branches
* git checkout -b <branches name>
* git branch 

If you push your changes and your repository already have latest changes 
and you forgot to pull that changes,so you cannot pull and push,so that problem
Solution follow below commands:-

* git config pull.rebase false
* git pull
* git push


## Setup username and email

* git config --global user.name "Your Name"

* git config --global user.email "your-email@example.com"

* git config --global user.name

* git config --global user.email

* git config --list

PGPASSWORD=postgres psql -h localhost -p 5433 -U postgres -d payment_poc -c "SELECT idempotency_key, request_hash, response_status, created_at FROM idempotency_keys ORDER BY created_at DESC LIMIT 10;" 2>&1