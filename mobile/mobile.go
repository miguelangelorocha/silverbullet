package mobile

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/silverbulletmd/silverbullet/client_bundle"
	"github.com/silverbulletmd/silverbullet/server"
)

// Server represents a running SilverBullet server instance
type Server struct {
	httpServer *http.Server
	config     *server.ServerConfig
	cancel     context.CancelFunc
	wg         sync.WaitGroup
	mu         sync.Mutex
	running    bool
}

// Config holds the configuration for starting the server
type Config struct {
	SpaceFolderPath string
	Port            int
	IndexPage       string
	ReadOnly        bool
}

var globalServer *Server

// NewServer creates a new server instance with the given configuration
func NewServer(spaceFolderPath string, port int) (*Server, error) {
	if spaceFolderPath == "" {
		return nil, fmt.Errorf("space folder path cannot be empty")
	}
	if port <= 0 {
		port = 3000
	}
	return &Server{
		config: &server.ServerConfig{
			BindHost: "127.0.0.1",
			Port:     port,
		},
		running: false,
	}, nil
}

// Start starts the SilverBullet server
func (s *Server) Start(spaceFolderPath string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.running {
		return fmt.Errorf("server is already running")
	}

	// Build the server configuration
	serverConfig := &server.ServerConfig{
		BindHost: "127.0.0.1",
		Port:     s.config.Port,
	}
	rootSpaceConfig := &server.SpaceConfig{
		IndexPage:        "index",
		SpaceName:        "SilverBullet",
		SpaceDescription: "Powerful and programmable note taking app",
		SpaceFolderPath:  spaceFolderPath,
		ReadOnlyMode:     false,
	}
	// Simple space config resolver
	serverConfig.SpaceConfigResolver = func(r *http.Request) (*server.SpaceConfig, error) {
		return rootSpaceConfig, nil
	}

	// Set up space primitives
	spacePrimitives, err := server.NewDiskSpacePrimitives(rootSpaceConfig.SpaceFolderPath, "")
	if err != nil {
		return fmt.Errorf("failed to create space primitives: %w", err)
	}
	// Extract the last modified time from the main binary
	bundlePathDate := time.Now()
	serverConfig.ClientBundle = server.NewReadOnlyFallthroughSpacePrimitives(
		client_bundle.BundledFiles,
		"client",
		bundlePathDate,
		nil,
	)
	rootSpaceConfig.SpacePrimitives = server.NewReadOnlyFallthroughSpacePrimitives(
		client_bundle.BundledFiles,
		"base_fs",
		bundlePathDate,
		spacePrimitives,
	)
	// Disable shell backend for mobile
	rootSpaceConfig.ShellBackend = server.NewNotSupportedShell()

	// Ensure index and config pages exist
	ensureIndexAndConfig(rootSpaceConfig)

	// Create the router
	r := server.Router(serverConfig)
	// Create HTTP server
	s.httpServer = &http.Server{
		Addr:    fmt.Sprintf("%s:%d", serverConfig.BindHost, serverConfig.Port),
		Handler: r,
	}
	s.config = serverConfig

	// Start server in background
	_, cancel := context.WithCancel(context.Background())
	s.cancel = cancel
	s.wg.Add(1)
	go func() {
		defer s.wg.Done()
		log.Printf("Starting SilverBullet server on http://127.0.0.1:%d", serverConfig.Port)
		if err := s.httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Printf("HTTP server error: %v", err)
		}
	}()
	s.running = true
	return nil
}

// Stop stops the SilverBullet server
func (s *Server) Stop() error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if !s.running {
		return nil
	}

	log.Println("Stopping SilverBullet server...")
	if s.cancel != nil {
		s.cancel()
	}
	if s.httpServer != nil {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if err := s.httpServer.Shutdown(ctx); err != nil {
			log.Printf("Server shutdown error: %v", err)
			return err
		}
	}
	s.wg.Wait()
	s.running = false
	log.Println("SilverBullet server stopped")
	return nil
}

// IsRunning returns whether the server is currently running
func (s *Server) IsRunning() bool {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.running
}

// GetURL returns the URL where the server is accessible
func (s *Server) GetURL() string {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.config != nil {
		return fmt.Sprintf("http://127.0.0.1:%d", s.config.Port)
	}
	return ""
}

// StartServer is a convenience function for Go Mobile binding
// It starts a server with the given space folder path and port
func StartServer(spaceFolderPath string, port int) error {
	if globalServer != nil && globalServer.IsRunning() {
		return fmt.Errorf("server is already running")
	}
	srv, err := NewServer(spaceFolderPath, port)
	if err != nil {
		return err
	}
	if err := srv.Start(spaceFolderPath); err != nil {
		return err
	}
	globalServer = srv
	return nil
}

// StopServer stops the currently running server
func StopServer() error {
	if globalServer == nil {
		return nil
	}
	err := globalServer.Stop()
	globalServer = nil
	return err
}

// GetServerURL returns the URL of the running server
func GetServerURL() string {
	if globalServer == nil {
		return ""
	}
	return globalServer.GetURL()
}

// IsServerRunning returns whether a server is currently running
func IsServerRunning() bool {
	if globalServer == nil {
		return false
	}
	return globalServer.IsRunning()
}

// ensureIndexAndConfig ensures index and config pages exist
func ensureIndexAndConfig(rootSpaceConfig *server.SpaceConfig) {
	// Index page
	indexPagePath := fmt.Sprintf("%s.md", rootSpaceConfig.IndexPage)
	_, err := rootSpaceConfig.SpacePrimitives.GetFileMeta(indexPagePath)
	if err == server.ErrNotFound {
		log.Printf("Index page %s does not exist, creating...", indexPagePath)
		indexContent := []byte("# Welcome to SilverBullet\n\nThis is your personal knowledge base.\n")
		if _, err := rootSpaceConfig.SpacePrimitives.WriteFile(indexPagePath, indexContent, nil); err != nil {
			log.Printf("Could not write index page: %v", err)
		}
	}

	// Config page
	configPagePath := "CONFIG.md"
	_, err = rootSpaceConfig.SpacePrimitives.GetFileMeta(configPagePath)
	if err == server.ErrNotFound {
		log.Printf("Config page %s does not exist, creating...", configPagePath)
		configContent := []byte("# Configuration\n\nThis is your configuration page.\n")
		if _, err := rootSpaceConfig.SpacePrimitives.WriteFile(configPagePath, configContent, nil); err != nil {
			log.Printf("Could not write config page: %v", err)
		}
	}
}

// GetVersion returns the SilverBullet version
func GetVersion() string {
	return "SilverBullet Mobile"
}
