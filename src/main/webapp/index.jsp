<%-- ====================================================================== --%>
<%-- index.jsp — Main Application Landing Page                               --%>
<%-- ====================================================================== --%>
<%-- This is a JavaServer Pages (JSP) file — it combines HTML markup with     --%>
<%-- embedded Java code. When Tomcat serves this page, it compiles the JSP    --%>
<%-- into a servlet, executes any Java code, and returns the resulting HTML   --%>
<%-- to the browser.                                                          --%>
<%--                                                                          --%>
<%-- In the original CodePipeline project, editing this file and pushing to   --%>
<%-- GitHub triggered the entire pipeline (Source → Build → Deploy).          --%>
<%-- Here, pushing changes triggers GitHub Actions instead.                   --%>
<%-- ====================================================================== --%>
<html>
<head>
    <title>Pipeline to Actions</title>
    <style>
        /* Simple styling to make the page visually clear */
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 { color: #232f3e; }
        .info { color: #666; margin-top: 20px; }
        .badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 0.85em;
            font-weight: bold;
        }
        .gh-actions { background: #2088ff; color: white; }
        .fargate { background: #ff9900; color: white; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Pipeline to Actions - CI/CD with GitHub Actions!</h1>

        <p>This application was built, tested, and deployed
           <strong>entirely by GitHub Actions</strong>.</p>

        <p>Running on <span class="badge fargate">AWS ECS Fargate</span>
           — no servers to manage!</p>

        <div class="info">
            <p><strong>Architecture:</strong></p>
            <ul>
                <li><span class="badge gh-actions">GitHub Actions</span> — CI/CD orchestration</li>
                <li><strong>GitHub Packages</strong> — Maven dependency registry</li>
                <li><strong>Amazon ECR</strong> — Docker image registry</li>
                <li><strong>ECS Fargate</strong> — Serverless container hosting</li>
                <li><strong>Terraform</strong> — Infrastructure as Code</li>
            </ul>
        </div>

        <%-- This JSP expression embeds live Java output into the HTML.     --%>
        <%-- It displays the server's current timestamp, proving the page   --%>
        <%-- is dynamically generated (not static HTML).                    --%>
        <p class="info">
            <em>Server Time: <%= new java.util.Date() %></em>
        </p>
    </div>
</body>
</html>

