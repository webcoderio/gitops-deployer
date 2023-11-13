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
	err := godotenv.Load()
	if err != nil {
		fmt.Println("Error loading .env file")
	}

	r := gin.Default()

	r.GET("/deploy/:repoId", func(c *gin.Context) {
		repoId := c.Param("repoId")
		if repoId == "" {
			repoId = "id1" // default
		}

		err := runDeployScript(repoId)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error":   true,
				"message": fmt.Sprintf("error deploying repository: %s", err),
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"message": fmt.Sprintf("deploy ID: %s deployment successful!", repoId),
		})
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	r.Run(":" + port)
}

func runDeployScript(repoId string) error {
	// todo: check if the sh file exists
	if repoId == "" {
		repoId = "id1"
	}

	cmd := exec.Command("bash", repoId+".sh")
	cmd.Dir = "./scripts"
	output, err := cmd.CombinedOutput()

	if err != nil {
		return fmt.Errorf("error executing command: %s", err)
	}

	fmt.Println(string(output))
	return nil
}
