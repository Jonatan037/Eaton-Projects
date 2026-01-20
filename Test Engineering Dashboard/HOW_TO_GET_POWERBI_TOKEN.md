# How to Get a Power BI Access Token (Step-by-Step with Pictures)

## What You Need
- Access to Power BI (https://app.powerbi.com)
- Chrome, Edge, or Firefox browser
- Your Eaton credentials

## Step-by-Step Instructions

### Step 1: Open Power BI and Login
1. Open your browser (Chrome recommended)
2. Go to https://app.powerbi.com
3. Sign in with: **JonatanDArias@eaton.com**

### Step 2: Open Developer Tools
**Option A - Using Keyboard:**
- Press **F12** on your keyboard

**Option B - Using Menu:**
- Chrome: Click the ⋮ menu (top right) → More Tools → Developer Tools
- Edge: Click the ⋯ menu (top right) → More Tools → Developer Tools
- Firefox: Click the ☰ menu → More Tools → Web Developer Tools

**What you should see:**
A panel will open at the bottom or side of your browser with tabs like "Elements", "Console", "Network", etc.

### Step 3: Go to the Network Tab
1. Look at the tabs in the Developer Tools panel
2. Click on the **Network** tab (it should be near the top)
3. You should see either:
   - An empty list (if no requests yet)
   - OR a list of network requests

**If you see a message saying "Recording network activity"** - that's good, it means it's ready!

### Step 4: Navigate to Your Dataflow
1. In the Power BI window (NOT the developer tools), navigate to:
   - Click "Workspaces" on the left sidebar
   - Click "CPDI-Business Intelligence and Analytics"
   - OR directly go to: https://app.powerbi.com/groups/ce0ff094-0f63-43e9-909a-c5bc60e3be4f

2. As the page loads, you'll see network requests appearing in the Network tab

### Step 5: Find an API Request
In the Network tab, look for requests that:
- Start with "api.powerbi.com" in the Name column
- OR have "dataflows" in the name
- OR just refresh the page and look for ANY request to "api.powerbi.com"

**Tip:** You can type "api.powerbi.com" in the filter box at the top of the Network tab to show only Power BI API calls.

### Step 6: Get the Token
1. **Click on any request** that goes to "api.powerbi.com"
   - The request will be highlighted
   - A details panel opens on the right

2. **Look for the "Headers" tab** (in the details panel on the right)
   - Click on "Headers" if it's not already selected

3. **Scroll down to "Request Headers"**
   - You'll see a list of headers like:
     - Accept: application/json
     - Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOi...
     - Content-Type: application/json
     - etc.

4. **Find the "Authorization" header**
   - It will look like: `Authorization: Bearer eyJ0eXAiOiJKV1Qi...`
   - The token is the long string AFTER "Bearer "

5. **Copy the token:**
   - **Method A (Easy):** 
     - Double-click on the token value (the part after "Bearer ")
     - Right-click → Copy
   
   - **Method B (Manual):**
     - Click at the start of the token (after "Bearer ")
     - Hold Shift and press End to select all
     - Press Ctrl+C to copy

**What the token looks like:**
```
eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ik1yNS1BVWliZkJpaTdOZDFqQmViYXhib1hXMCIsImtpZCI6Ik1yNS1BVWliZkJpaTdOZDFqQmViYXhib1hXMCJ9.eyJhdWQiOiJodHRwczovL2FuYWx5c2lzLndpbmRvd3MubmV0L3Bvd2VyYmkvYXBpIiwiaXNzIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvNzQ3NWY2YjEtZmY1MS00MjQwLWI3NzQtY2QwMGMwZTZlZGZhLyIsImlhdCI6MTcwNTYwNzE4OCwibmJmIjoxNzA1NjA3MTg4LCJleHAiOjE3MDU2MTExODgsImFjY3QiOjAsImFjciI6IjEiLCJhaW8iOiJBVFFBeS84VkFBQUF...
(very long, continues for many lines)
```

It's a very long string (500+ characters) that starts with "eyJ" and has lots of random-looking characters.

### Step 7: Paste the Token in the Test Page
1. Go to your test page: http://your-server/Test%20Engineering%20Dashboard/TestPowerBIConnection.aspx
2. Find the text box under "Access Token (for testing):"
3. **Click in the box and paste the token** (Ctrl+V)
4. Click the **"Test Connection with Token"** button

### Expected Result
You should see:
- ✅ "Connection successful! Retrieved XXX records."
- A table showing the first 100 rows of data
- Column information listing all available fields

## Troubleshooting

### I don't see the Network tab
- Make sure Developer Tools are open (press F12)
- Look for tabs at the top of the Developer Tools panel
- Try clicking the >> button if there are too many tabs

### I don't see any requests to api.powerbi.com
- Try refreshing the Power BI page while the Network tab is open
- Clear the network log and try again (click the 🚫 icon in Network tab)
- Make sure you're actually in a Power BI workspace, not just the home page

### I can't find the Authorization header
- Make sure you clicked on a request to "api.powerbi.com"
- Look in the "Headers" tab of the request details
- Scroll down to "Request Headers" section
- It should be near the top of the request headers list

### The token is too long to copy
- That's normal! Tokens are typically 800-2000 characters
- Make sure you copy the ENTIRE string
- Don't include "Bearer " in what you copy - just the token part

### Test page says "401 Unauthorized"
- Your token expired (they last ~1 hour)
- Get a fresh token by repeating the steps
- Make sure you copied the entire token

### Test page says "403 Forbidden"
- Your account doesn't have access to the dataflow
- Verify you can see the dataflow in Power BI
- Contact the workspace admin

## Quick Reference

**Power BI URLs:**
- Main Power BI: https://app.powerbi.com
- Your Workspace: https://app.powerbi.com/groups/ce0ff094-0f63-43e9-909a-c5bc60e3be4f
- Test Page: http://your-server/Test%20Engineering%20Dashboard/TestPowerBIConnection.aspx

**Token Format:**
- Starts with: `eyJ`
- Length: 800-2000 characters
- Looks like: `eyJ0eXAiOiJKV1QiLCJhbGc...` (lots of random characters)
- Valid for: ~1 hour

**Network Tab Tips:**
- Press F12 to open Developer Tools
- Go to Network tab
- Filter by: "api.powerbi.com"
- Look in: Request Headers → Authorization
- Copy: Everything after "Bearer "
