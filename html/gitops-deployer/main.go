package main

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"net/http"
	"os"
	"os/exec"
)

func main() {
	fmt.Println("Starting Gin server...")
	err := godotenv.Load()
	if err != nil {
		fmt.Println("error loading .env file")
	}

	route := gin.Default()
	route.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "Hello, This is GitOPS Deployer.",
		})
	})

	route.GET("/deploy/:deployId", func(c *gin.Context) {
		// deploy id
		deployId := c.Param("deployId")
		if deployId == "" {
			deployId = "id1" // default
		}

		githubToken := c.Param("githubToken")
		if githubToken == "" {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error":   true,
				"message": "Github Token is required to be post from github pipeline encrypted",
			})
		}

		err := runDeployScript(deployId, githubToken)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error":   true,
				"message": fmt.Sprintf("error deploying repository: %s", err),
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"message": fmt.Sprintf("deploy ID: %s deployment successful!", deployId),
		})
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	route.Run(":" + port)
}

func runDeployScript(deployId string, githubToken string) error {
	// todo: check if the sh file exists
	if deployId == "" {
		deployId = "id1"
	}

	cmd := exec.Command("bash", deployId+".sh", deployId, githubToken)
	cmd.Dir = "./scripts"

	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("error executing command: %s", err)
	}

	fmt.Println(string(output))
	return nil
}
