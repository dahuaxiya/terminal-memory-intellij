package com.terminalmemory.service

import com.google.gson.Gson
import com.google.gson.JsonObject
import com.intellij.openapi.components.Service
import com.intellij.openapi.components.service
import com.intellij.openapi.diagnostic.Logger
import com.intellij.openapi.project.Project
import com.intellij.openapi.ui.Messages
import com.intellij.openapi.wm.ToolWindowManager
import com.terminalmemory.ui.TerminalMemoryToolWindowPanel
import org.jetbrains.plugins.terminal.TerminalView
import org.jetbrains.plugins.terminal.TerminalToolWindowManager
import java.io.BufferedReader
import java.io.InputStreamReader
import java.security.MessageDigest

@Service(Service.Level.PROJECT)
class TerminalMemoryProjectService(private val project: Project) {
    
    private val LOG = Logger.getInstance(TerminalMemoryProjectService::class.java)
    private val gson = Gson()
    
    // Settings (should be loaded from persistence)
    private var pythonPath: String = "/usr/bin/python3"
    private var coreModulePath: String = ""
    
    init {
        // Try to detect core module path
        val userHome = System.getProperty("user.home")
        coreModulePath = "$userHome/.terminal-memory/core"
    }
    
    fun configure(pythonPath: String, coreModulePath: String) {
        this.pythonPath = pythonPath
        this.coreModulePath = coreModulePath
    }
    
    fun getPythonPath(): String = pythonPath
    fun getCoreModulePath(): String = coreModulePath
    
    /**
     * Get workspace ID based on project path
     */
    private fun getWorkspaceId(): String {
        val projectPath = project.basePath ?: return "unknown"
        val digest = MessageDigest.getInstance("MD5")
        val hash = digest.digest(projectPath.toByteArray())
        return hash.joinToString("") { "%02x".format(it) }.substring(0, 16)
    }
    
    /**
     * Get project info
     */
    private fun getProjectInfo(): JsonObject {
        val info = JsonObject()
        info.addProperty("ide_type", "intellij")
        info.addProperty("project_path", project.basePath ?: "")
        info.addProperty("ide_version", com.intellij.openapi.application.ApplicationInfo.getInstance().fullVersion)
        return info
    }
    
    /**
     * Execute Python CLI command
     */
    private fun executePython(action: String, data: JsonObject = JsonObject()): JsonObject? {
        try {
            val cliPath = "$coreModulePath/cli.py"
            val workspaceId = getWorkspaceId()
            val projectInfo = getProjectInfo()
            
            // Merge project info into data
            data.entrySet().forEach { projectInfo.add(it.key, it.value) }
            
            val processBuilder = ProcessBuilder(
                pythonPath,
                cliPath,
                action,
                workspaceId,
                gson.toJson(projectInfo)
            )
            
            // Set environment variables
            processBuilder.environment()["WORKSPACE_ID"] = workspaceId
            processBuilder.environment()["IDE_TYPE"] = "intellij"
            processBuilder.environment()["PROJECT_PATH"] = project.basePath ?: ""
            
            processBuilder.redirectErrorStream(true)
            val process = processBuilder.start()
            
            // Read output
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val output = StringBuilder()
            var line: String?
            while (reader.readLine().also { line = it } != null) {
                output.append(line)
            }
            
            process.waitFor()
            
            LOG.info("Python CLI output: $output")
            
            return gson.fromJson(output.toString(), JsonObject::class.java)
        } catch (e: Exception) {
            LOG.error("Failed to execute Python CLI", e)
            return null
        }
    }
    
    /**
     * Get all active terminals using Java reflection for compatibility
     */
    private fun getActiveTerminals(): List<TerminalInfo> {
        val terminals = mutableListOf<TerminalInfo>()
        
        try {
            val terminalView = TerminalView.getInstance(project)
            
            // Use Java reflection to access widgets
            val widgets: List<*> = try {
                // Try getTerminalWidgets() method
                val method = terminalView.javaClass.getMethod("getTerminalWidgets")
                method.invoke(terminalView) as? List<*>
            } catch (e: Exception) {
                try {
                    // Try getWidgets() method
                    val method = terminalView.javaClass.getMethod("getWidgets")
                    method.invoke(terminalView) as? List<*>
                } catch (e2: Exception) {
                    try {
                        // Try terminalWidgets field
                        val field = terminalView.javaClass.getDeclaredField("terminalWidgets")
                        field.isAccessible = true
                        field.get(terminalView) as? List<*>
                    } catch (e3: Exception) {
                        try {
                            // Try widgets field
                            val field = terminalView.javaClass.getDeclaredField("widgets")
                            field.isAccessible = true
                            field.get(terminalView) as? List<*>
                        } catch (e4: Exception) {
                            LOG.warn("All reflection attempts failed")
                            emptyList<Any>()
                        }
                    }
                }
            } ?: emptyList<Any>()
            
            LOG.info("Found ${widgets.size} terminals via reflection")
            
            for ((index, widget) in widgets.withIndex()) {
                val title = try {
                    widget?.let { w ->
                        try {
                            val titleMethod = w.javaClass.getMethod("getTerminalTitle")
                            titleMethod.invoke(w)?.toString()
                        } catch (e: Exception) {
                            "Terminal ${index + 1}"
                        }
                    } ?: "Terminal ${index + 1}"
                } catch (e: Exception) {
                    "Terminal ${index + 1}"
                }
                
                terminals.add(TerminalInfo(
                    id = "terminal_$index",
                    title = title,
                    tty = "unknown"
                ))
            }
            
            // Fallback: count content tabs in Terminal tool window
            if (terminals.isEmpty()) {
                val toolWindow = ToolWindowManager.getInstance(project).getToolWindow("Terminal")
                val contentCount = toolWindow?.contentManager?.contentCount ?: 0
                LOG.info("Terminal tool window has $contentCount tabs")
                
                if (contentCount > 0) {
                    for (i in 0 until contentCount) {
                        val content = toolWindow?.contentManager?.getContent(i)
                        val title = content?.displayName ?: "Terminal ${i + 1}"
                        terminals.add(TerminalInfo(
                            id = "terminal_$i",
                            title = title,
                            tty = "unknown"
                        ))
                    }
                }
            }
        } catch (e: Exception) {
            LOG.error("Failed to get active terminals", e)
        }
        
        LOG.info("Total terminals found: ${terminals.size}")
        return terminals
    }
    
    /**
     * Save all terminal sessions
     */
    fun saveSessions(): Boolean {
        val terminals = getActiveTerminals()
        
        if (terminals.isEmpty()) {
            Messages.showInfoMessage(project, "No active terminals to save.", "Terminal Memory")
            return false
        }
        
        val data = JsonObject()
        val terminalsArray = gson.toJsonTree(terminals).asJsonArray
        data.add("terminals", terminalsArray)
        
        val result = executePython("capture", data)
        
        return if (result != null && result.get("success")?.asBoolean == true) {
            val count = result.get("sessions")?.asJsonArray?.size() ?: 0
            Messages.showInfoMessage(project, "Saved $count terminal session(s).", "Terminal Memory")
            refreshToolWindow()
            true
        } else {
            val error = result?.get("error")?.asString ?: "Unknown error"
            Messages.showErrorDialog(project, "Failed to save sessions: $error", "Terminal Memory")
            false
        }
    }
    
    /**
     * Restore terminal sessions
     */
    fun restoreSessions(): Boolean {
        // Check if has saved state
        val hasState = executePython("has_state", JsonObject())
        if (hasState == null || hasState.get("has_state")?.asBoolean != true) {
            Messages.showInfoMessage(project, "No saved terminal sessions found.", "Terminal Memory")
            return false
        }
        
        // Get restore commands
        val result = executePython("restore_commands", JsonObject())
        
        if (result == null) {
            Messages.showErrorDialog(project, "Failed to get restore commands.", "Terminal Memory")
            return false
        }
        
        if (result.get("success")?.asBoolean != true) {
            val error = result.get("error")?.asString ?: "Unknown error"
            Messages.showErrorDialog(project, "Failed to restore sessions: $error", "Terminal Memory")
            return false
        }
        
        val commands = result.getAsJsonArray("commands")
        var restoredCount = 0
        
        try {
            val terminalView = TerminalView.getInstance(project)
            
            for (element in commands) {
                val cmd = element.asJsonObject
                val cwd = cmd.get("cwd")?.asString
                val commandList = cmd.getAsJsonArray("commands")
                val agent = cmd.getAsJsonObject("agent")
                
                // Create terminal name based on agent
                val terminalName = when (agent?.get("type")?.asString) {
                    "kimi" -> "Kimi - Restored"
                    "claude" -> "Claude - Restored"
                    "codex" -> "Codex - Restored"
                    else -> "Restored Terminal"
                }
                
                // Create new terminal
                val widget = terminalView.createLocalShellWidget(cwd, terminalName)
                
                // Execute commands
                for (cmdElement in commandList) {
                    val command = cmdElement.asString
                    widget.executeCommand(command)
                    Thread.sleep(100) // Small delay between commands
                }
                
                restoredCount++
            }
            
            Messages.showInfoMessage(project, "Restored $restoredCount terminal(s).", "Terminal Memory")
            refreshToolWindow()
            return true
        } catch (e: Exception) {
            LOG.error("Failed to restore terminals", e)
            Messages.showErrorDialog(project, "Failed to restore sessions: ${e.message}", "Terminal Memory")
            return false
        }
    }
    
    /**
     * Show status
     */
    fun showStatus() {
        val result = executePython("status", JsonObject())
        
        if (result == null) {
            Messages.showErrorDialog(project, "Failed to get status.", "Terminal Memory")
            return
        }
        
        if (result.get("has_state")?.asBoolean != true) {
            Messages.showInfoMessage(project, "No saved terminal sessions found.", "Terminal Memory")
            return
        }
        
        val summary = result.getAsJsonObject("summary")
        val terminalCount = summary.get("terminal_count")?.asInt ?: 0
        val projectPath = summary.get("project_path")?.asString ?: "Unknown"
        val lastSaved = summary.get("last_saved")?.asString ?: "Unknown"
        val agentCounts = summary.getAsJsonObject("agent_counts")
        
        val message = buildString {
            append("<html><body>")
            append("<h3>Saved Terminal Sessions</h3>")
            append("<p><b>Project:</b> $projectPath</p>")
            append("<p><b>Terminals:</b> $terminalCount</p>")
            
            if (agentCounts != null && agentCounts.size() > 0) {
                append("<p><b>AI Agents:</b></p><ul>")
                agentCounts.entrySet().forEach { entry ->
                    append("<li>${entry.key}: ${entry.value.asInt}</li>")
                }
                append("</ul>")
            }
            
            append("<p><b>Last Saved:</b> $lastSaved</p>")
            append("</body></html>")
        }
        
        Messages.showInfoMessage(project, message, "Terminal Memory Status")
    }
    
    /**
     * Clear saved state
     */
    fun clearSavedState() {
        val result = Messages.showYesNoDialog(
            project,
            "Are you sure you want to clear all saved terminal sessions?",
            "Clear Saved State",
            Messages.getQuestionIcon()
        )
        
        if (result == Messages.YES) {
            executePython("clear", JsonObject())
            Messages.showInfoMessage(project, "Saved state cleared.", "Terminal Memory")
            refreshToolWindow()
        }
    }
    
    /**
     * Check and offer restore on startup
     */
    fun checkAndOfferRestore() {
        val result = executePython("has_state", JsonObject())
        
        if (result != null && result.get("has_state")?.asBoolean == true) {
            val summary = result.getAsJsonObject("summary")
            val terminalCount = summary.get("terminal_count")?.asInt ?: 0
            val agentCounts = summary.getAsJsonObject("agent_counts")
            
            val agentInfo = agentCounts?.entrySet()?.joinToString(", ") { "${it.key}: ${it.value.asInt}" } ?: "none"
            
            val message = "Found saved terminal sessions:\n$terminalCount terminal(s) with AI agents: $agentInfo"
            
            val dialogResult = Messages.showYesNoDialog(
                project,
                message,
                "Restore Terminal Sessions?",
                "Restore",
                "Ignore",
                Messages.getQuestionIcon()
            )
            
            if (dialogResult == Messages.YES) {
                restoreSessions()
            }
        }
    }
    
    /**
     * Get saved state summary for UI
     */
    fun getSavedStateSummary(): SavedStateSummary? {
        val result = executePython("status", JsonObject())
        
        if (result == null || result.get("has_state")?.asBoolean != true) {
            return null
        }
        
        val summary = result.getAsJsonObject("summary")
        return SavedStateSummary(
            workspaceId = summary.get("workspace_id")?.asString ?: "",
            terminalCount = summary.get("terminal_count")?.asInt ?: 0,
            agentCounts = summary.getAsJsonObject("agent_counts")?.entrySet()?.associate { 
                it.key to it.value.asInt 
            } ?: emptyMap(),
            lastSaved = summary.get("last_saved")?.asString ?: ""
        )
    }
    
    /**
     * Refresh tool window
     */
    private fun refreshToolWindow() {
        val toolWindow = ToolWindowManager.getInstance(project).getToolWindow("Terminal Memory")
        val content = toolWindow?.contentManager?.getContent(0)
        val panel = content?.component as? TerminalMemoryToolWindowPanel
        panel?.refresh()
    }
    
    companion object {
        fun getInstance(project: Project): TerminalMemoryProjectService = project.service()
    }
}

// Data classes
data class TerminalInfo(
    val id: String,
    val title: String,
    val tty: String
)

data class SavedStateSummary(
    val workspaceId: String,
    val terminalCount: Int,
    val agentCounts: Map<String, Int>,
    val lastSaved: String
)
