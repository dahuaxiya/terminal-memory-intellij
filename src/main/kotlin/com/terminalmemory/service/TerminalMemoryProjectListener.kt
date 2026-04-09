package com.terminalmemory.service

import com.intellij.openapi.components.service
import com.intellij.openapi.project.Project
import com.intellij.openapi.project.ProjectManagerListener
import com.intellij.openapi.startup.StartupActivity
import com.intellij.openapi.diagnostic.Logger

/**
 * Project lifecycle listener for auto-save and auto-restore
 */
class TerminalMemoryProjectListener : ProjectManagerListener {
    
    private val LOG = Logger.getInstance(TerminalMemoryProjectListener::class.java)
    
    override fun projectClosing(project: Project) {
        LOG.info("Project closing: ${project.name}")
        
        // Auto-save on close
        val settings = TerminalMemorySettings.getInstance(project)
        if (settings.autoSave) {
            try {
                val service = TerminalMemoryProjectService.getInstance(project)
                service.saveSessions()
                LOG.info("Auto-saved terminal sessions on project close")
            } catch (e: Exception) {
                LOG.error("Failed to auto-save terminal sessions", e)
            }
        }
    }
}

/**
 * Startup activity for auto-restore
 */
class TerminalMemoryStartupActivity : StartupActivity {
    
    private val LOG = Logger.getInstance(TerminalMemoryStartupActivity::class.java)
    
    override fun runActivity(project: Project) {
        LOG.info("Project opened: ${project.name}")
        
        val settings = TerminalMemorySettings.getInstance(project)
        
        // Auto-restore on startup (if enabled)
        if (settings.autoRestore) {
            try {
                val service = TerminalMemoryProjectService.getInstance(project)
                service.checkAndOfferRestore()
            } catch (e: Exception) {
                LOG.error("Failed to check/restore terminal sessions", e)
            }
        }
    }
}

/**
 * Settings state
 */
class TerminalMemorySettings(private val project: Project) {
    
    var autoSave: Boolean = true
    var autoRestore: Boolean = false
    var confirmOnRestore: Boolean = true
    var pythonPath: String = "/usr/bin/python3"
    var coreModulePath: String = ""
    
    init {
        // Load from persistence (simplified - should use PersistentStateComponent)
        val userHome = System.getProperty("user.home")
        coreModulePath = "$userHome/.terminal-memory/core"
    }
    
    companion object {
        fun getInstance(project: Project): TerminalMemorySettings {
            return TerminalMemorySettings(project)
        }
    }
}
