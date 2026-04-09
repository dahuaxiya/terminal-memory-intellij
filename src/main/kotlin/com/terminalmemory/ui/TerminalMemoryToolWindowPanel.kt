package com.terminalmemory.ui

import com.intellij.openapi.project.Project
import com.intellij.openapi.ui.SimpleToolWindowPanel
import com.intellij.ui.components.JBLabel
import com.intellij.ui.components.JBPanel
import com.intellij.ui.components.JBScrollPane
import com.intellij.util.ui.JBUI
import com.terminalmemory.service.TerminalMemoryProjectService
import com.terminalmemory.service.SavedStateSummary
import java.awt.BorderLayout
import java.awt.FlowLayout
import java.awt.GridBagConstraints
import java.awt.GridBagLayout
import javax.swing.*

class TerminalMemoryToolWindowPanel(private val project: Project) : SimpleToolWindowPanel(false, true) {
    
    private val contentPanel = JBPanel<JBPanel<*>>(GridBagLayout())
    private val service = TerminalMemoryProjectService.getInstance(project)
    
    init {
        // Toolbar with actions
        val toolbar = createToolbar()
        setToolbar(toolbar)
        
        // Content panel
        contentPanel.border = JBUI.Borders.empty(10)
        val scrollPane = JBScrollPane(contentPanel)
        setContent(scrollPane)
        
        // Initial refresh
        refresh()
    }
    
    private fun createToolbar(): JComponent {
        val panel = JPanel(FlowLayout(FlowLayout.LEFT))
        
        val refreshButton = JButton("Refresh").apply {
            addActionListener { refresh() }
        }
        
        val saveButton = JButton("Save").apply {
            addActionListener { 
                service.saveSessions()
                refresh()
            }
        }
        
        val restoreButton = JButton("Restore").apply {
            addActionListener {
                service.restoreSessions()
                refresh()
            }
        }
        
        panel.add(saveButton)
        panel.add(restoreButton)
        panel.add(refreshButton)
        
        return panel
    }
    
    fun refresh() {
        contentPanel.removeAll()
        
        val summary = service.getSavedStateSummary()
        
        if (summary == null) {
            showEmptyState()
        } else {
            showSummary(summary)
        }
        
        contentPanel.revalidate()
        contentPanel.repaint()
    }
    
    private fun showEmptyState() {
        val constraints = GridBagConstraints().apply {
            gridx = 0
            gridy = 0
            weightx = 1.0
            weighty = 1.0
            anchor = GridBagConstraints.CENTER
        }
        
        val label = JBLabel("No saved terminal sessions", SwingConstants.CENTER)
        label.foreground = UIManager.getColor("Label.disabledForeground")
        contentPanel.add(label, constraints)
        
        val hintConstraints = GridBagConstraints().apply {
            gridx = 0
            gridy = 1
            weightx = 1.0
            insets = JBUI.insetsTop(10)
            anchor = GridBagConstraints.CENTER
        }
        
        val hintLabel = JBLabel("Use 'Save' button to capture current terminals", SwingConstants.CENTER)
        hintLabel.foreground = UIManager.getColor("Label.disabledForeground")
        contentPanel.add(hintLabel, hintConstraints)
    }
    
    private fun showSummary(summary: SavedStateSummary) {
        var row = 0
        
        // Header
        val headerLabel = JBLabel("Saved Terminal Sessions", SwingConstants.LEFT)
        headerLabel.font = headerLabel.font.deriveFont(java.awt.Font.BOLD, 14f)
        
        contentPanel.add(headerLabel, createConstraints(row++, 0, 2))
        
        // Separator
        contentPanel.add(JSeparator(), createConstraints(row++, 0, 2, fill = true))
        
        // Terminal count
        val countLabel = JBLabel("Terminals: ${summary.terminalCount}")
        contentPanel.add(countLabel, createConstraints(row++, 0))
        
        // AI Agents
        if (summary.agentCounts.isNotEmpty()) {
            contentPanel.add(JBLabel("AI Agents:"), createConstraints(row++, 0))
            
            summary.agentCounts.forEach { (agent, count) ->
                val agentLabel = JBLabel("  • $agent: $count")
                contentPanel.add(agentLabel, createConstraints(row++, 0))
            }
        }
        
        // Last saved
        val lastSaved = formatLastSaved(summary.lastSaved)
        val savedLabel = JBLabel("Last saved: $lastSaved")
        contentPanel.add(savedLabel, createConstraints(row++, 0))
        
        // Separator
        contentPanel.add(JSeparator(), createConstraints(row++, 0, 2, fill = true))
        
        // Actions panel
        val actionsPanel = JPanel(FlowLayout(FlowLayout.LEFT))
        
        val clearButton = JButton("Clear").apply {
            foreground = UIManager.getColor("Label.errorForeground")
            addActionListener {
                service.clearSavedState()
                refresh()
            }
        }
        actionsPanel.add(clearButton)
        
        contentPanel.add(actionsPanel, createConstraints(row++, 0, 2))
        
        // Push everything to top
        val spacerConstraints = GridBagConstraints().apply {
            gridx = 0
            gridy = row
            weightx = 1.0
            weighty = 1.0
            fill = GridBagConstraints.BOTH
        }
        contentPanel.add(JPanel(), spacerConstraints)
    }
    
    private fun createConstraints(
        row: Int, 
        col: Int, 
        width: Int = 1,
        fill: Boolean = false
    ): GridBagConstraints {
        return GridBagConstraints().apply {
            gridx = col
            gridy = row
            gridwidth = width
            insets = JBUI.insets(5)
            anchor = GridBagConstraints.WEST
            if (fill) {
                this.fill = GridBagConstraints.HORIZONTAL
                weightx = 1.0
            }
        }
    }
    
    private fun formatLastSaved(isoDate: String): String {
        return try {
            // Parse ISO date and format nicely
            val instant = java.time.Instant.parse(isoDate)
            val dateTime = java.time.LocalDateTime.ofInstant(
                instant, 
                java.time.ZoneId.systemDefault()
            )
            dateTime.format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"))
        } catch (e: Exception) {
            isoDate
        }
    }
}
