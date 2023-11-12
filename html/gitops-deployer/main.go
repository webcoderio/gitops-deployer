package main

import (
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		fmt.Println("Error loading .env file")
	}

	r := gin.Default()

	r.GET("/deploy/:repoName", func(c *gin.Context) {
		repoName := c.Param("repoName")
		err := runDeployScript(repoName)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error":   true,
				"message": fmt.Sprintf("Error deploying repository: %s", err),
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"message": fmt.Sprintf("Repository %s deployment successful!", repoName),
		})
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	r.Run(":" + port)
}

func runDeployScript(repoName string) error {
    // id
	scriptName := fmt.Sprintf("%s.sh", repoName)
    // todo: check if the sh file exists
	if scriptName == "" {
		return fmt.Errorf("Deployment script not found for repository: %s", repoName)
	}

	repoId = fmt.Sprintf("%s_ID", strings.ToUpper(repoName))

	// env pattern
	repoURLKey := fmt.Sprintf("%s_REPO_URL", repoId)
	repoBranchKey := fmt.Sprintf("%s_REPO_BRANCH", repoId)
	domainKey := fmt.Sprintf("%s_DOMAIN", repoId)
	deployPathKey := fmt.Sprintf("%s_DEPLOY_PATH", repoId)
	deployPathIgnoreKey := fmt.Sprintf("%s_DEPLOY_PATH_IGNORE", repoId)

    # variables
	scriptName = os.Getenv(scriptName)
	repoURL := os.Getenv(repoURLKey)
	repoBranch := os.Getenv(repoBranchKey)
	domain := os.Getenv(domainKey)
	deployPath := os.Getenv(deployPathKey)
	deployPathIgnore := os.Getenv(deployPathIgnoreKey)

	cmd := exec.Command("bash", scriptName, repoURL, repoBranch, domain, deployPath, deployPathIgnore)
	output, err := cmd.CombinedOutput()

	if err != nil {
		return fmt.Errorf("Error executing command: %s", err)
	}

	fmt.Println(string(output))
	return
