If i create any branches on the git hub then need to run some commands in terminal
git fetch
git checkout <new-branch>

after added your changes
git add .
git commit -m "message"
git push

after done your terminal side you go to the git hub side 

first go to Pull Request

you enter which branch merge Request and which is your changes branch 

after that write some releted comments and assign to reviewer and enter ready to review

============================================================================================
# Creating a Branch and Raising a Pull Request (PR)

## Step 1: Fetch the Latest Changes

Before starting work, fetch the latest changes from the remote repository:

```bash
git fetch
```

## Step 2: Switch to Your Branch

Checkout the branch you want to work on:

```bash
git checkout <branch-name>
```

Example:

```bash
git checkout feature/p2p-widget
```

If the branch does not exist locally:

```bash
git checkout -b <branch-name> origin/<branch-name>
```

---

## Step 3: Make Your Changes

Complete your development work and verify that everything is working correctly.

---

## Step 4: Stage the Changes

Add the modified files to Git:

```bash
git add .
```

Alternatively, add specific files:

```bash
git add <file-name>
```

---

## Step 5: Commit the Changes

Create a meaningful commit message:

```bash
git commit -m "Added Procure-to-Pay Pipeline dashboard widget"
```

---

## Step 6: Push Changes to GitHub

Push your branch to the remote repository:

```bash
git push origin <branch-name>
```

Example:

```bash
git push origin feature/p2p-widget
```

---

# Creating a Pull Request (PR)

## Step 7: Open GitHub

Navigate to the GitHub repository.

---

## Step 8: Create a Pull Request

1. Click **Pull Requests**.
2. Click **New Pull Request**.
3. Select the **Target Branch** (the branch into which your code will be merged).
4. Select your **Source Branch** (the branch containing your changes).

Example:

```text
Base Branch: develop
Compare Branch: feature/p2p-widget
```

---

## Step 9: Add PR Details

Provide the following information:

### Title

A short and meaningful title describing the change.

Example:

```text
Added Procure-to-Pay Pipeline Dashboard Widget
```

### Description

Include:

* Summary of changes
* Business requirement
* Screenshots (if applicable)
* Testing performed
* Any special notes for reviewers

---

## Step 10: Assign Reviewers

Assign the appropriate reviewer(s) who will validate your changes.

---

## Step 11: Mark as Ready for Review

After confirming all changes are complete:

1. Click **Ready for Review**
2. Submit the Pull Request

---

## Step 12: Address Review Comments

If reviewers request changes:

1. Make the required updates.
2. Commit the changes.
3. Push the changes to the same branch.

```bash
git add .
git commit -m "Addressed PR review comments"
git push
```

The Pull Request will automatically update with the new changes.

---

## Step 13: Merge the Pull Request

Once the Pull Request is approved:

1. Merge the Pull Request.
2. Delete the feature branch if no longer needed.

Example:

```bash
git branch -d <branch-name>
```

and optionally:

```bash
git push origin --delete <branch-name>
```
