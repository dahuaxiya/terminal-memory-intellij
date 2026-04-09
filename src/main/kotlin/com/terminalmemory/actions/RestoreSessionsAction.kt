package com.terminalmemory.actions

import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent
import com.terminalmemory.service.TerminalMemoryProjectService

class RestoreSessionsAction : AnAction("Restore Terminal Sessions") {
    
    override fun actionPerformed(e: AnActionEvent) {
        val project = e.project ?: return
        val service = TerminalMemoryProjectService.getInstance(project)
        service.restoreSessions()
    }
    
    override fun update(e: AnActionEvent) {
        e.presentation.isEnabled = e.project != null
    }
}
