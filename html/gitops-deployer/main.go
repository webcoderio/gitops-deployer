package main

import (
	"fmt"
	"net/http"
	"os/exec"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	r.GET("/execute-script", func(c *gin.Context) {
		cmd := exec.Command("bash", "scripts/echo.sh") // Replace with the actual path to your script
		output, err := cmd.CombinedOutput()

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error":   true,
				"message": fmt.Sprintf("Error executing command: %s", err),
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"output": string(output),
		})
	})

	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "Hello, Gin!",
		})
	})

	r.Run(":8080")
}
