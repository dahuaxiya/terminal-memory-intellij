package com.terminalmemory.actions

import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent
import com.intellij.openapi.components.service
import com.intellij.openapi.project.Project
import com.terminalmemory.service.TerminalMemoryProjectService

class SaveSessionsAction : AnAction("Save Terminal Sessions") {
    
    override fun actionPerformed(e: AnActionEvent) {
        val project = e.project ?: return
        val service = TerminalMemoryProjectService.getInstance(project)
        service.saveSessions()
    }
    
    override fun update(e: AnActionEvent) {
        // Enable only when project is open
        e.presentation.isEnabled = e.project != null
    }
}
