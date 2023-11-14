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

	route.POST("/deploy/:deployId", func(c *gin.Context) {
		// deploy id
		deployId := c.Param("deployId")
		if deployId == "" {
			deployId = "id1" // default
		}

		tokens, exists := c.Request.Header["Tokens"]
		fmt.Println(c.Request.Header)
		if !exists || len(tokens) == 0 {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Token is missing"})
			return
		}

		err := runScript(deployId, tokens[0])
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error":   true,
				"message": fmt.Sprintf("error deploying with error."),
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

func runScript(deployId string, token string) error {
	// todo: check if the sh file exists
	if deployId == "" {
		deployId = "id1"
	}

	cmd := exec.Command("bash", deployId+".sh", deployId, token)
	cmd.Dir = "./scripts"

	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("error executing command: %s", err)
	}

	fmt.Println(string(output))
	return nil
}
