package com.terminalmemory.ui

import com.intellij.openapi.options.Configurable
import com.intellij.openapi.project.Project
import com.terminalmemory.service.TerminalMemoryProjectService
import com.terminalmemory.service.TerminalMemorySettings
import java.awt.GridBagConstraints
import java.awt.GridBagLayout
import java.awt.Insets
import javax.swing.*

class TerminalMemorySettingsConfigurable(private val project: Project) : Configurable {
    
    private var mainPanel: JPanel? = null
    private var pythonPathField: JTextField? = null
    private var coreModulePathField: JTextField? = null
    private var autoSaveCheckBox: JCheckBox? = null
    private var autoRestoreCheckBox: JCheckBox? = null
    private var confirmOnRestoreCheckBox: JCheckBox? = null
    
    private val service = TerminalMemoryProjectService.getInstance(project)
    private val settings = TerminalMemorySettings.getInstance(project)
    
    override fun getDisplayName(): String = "Terminal Memory"
    
    override fun createComponent(): JComponent {
        val panel = JPanel(GridBagLayout())
        
        val constraints = GridBagConstraints().apply {
            fill = GridBagConstraints.HORIZONTAL
            insets = Insets(5, 5, 5, 5)
            gridx = 0
            weightx = 0.0
        }
        
        val valueConstraints = GridBagConstraints().apply {
            fill = GridBagConstraints.HORIZONTAL
            insets = Insets(5, 5, 5, 5)
            gridx = 1
            weightx = 1.0
        }
        
        // Python Path
        constraints.gridy = 0
        valueConstraints.gridy = 0
        panel.add(JLabel("Python Path:"), constraints)
        pythonPathField = JTextField(30)
        panel.add(pythonPathField, valueConstraints)
        
        // Core Module Path
        constraints.gridy = 1
        valueConstraints.gridy = 1
        panel.add(JLabel("Core Module Path:"), constraints)
        coreModulePathField = JTextField(30)
        panel.add(coreModulePathField, valueConstraints)
        
        // Separator
        constraints.gridy = 2
        constraints.gridwidth = 2
        panel.add(JSeparator(), constraints)
        constraints.gridwidth = 1
        
        // Auto Save
        constraints.gridy = 3
        valueConstraints.gridy = 3
        panel.add(JLabel("Auto Save:"), constraints)
        autoSaveCheckBox = JCheckBox("Save terminal sessions when closing IDE")
        panel.add(autoSaveCheckBox, valueConstraints)
        
        // Auto Restore
        constraints.gridy = 4
        valueConstraints.gridy = 4
        panel.add(JLabel("Auto Restore:"), constraints)
        autoRestoreCheckBox = JCheckBox("Offer to restore sessions when opening IDE")
        panel.add(autoRestoreCheckBox, valueConstraints)
        
        // Confirm on Restore
        constraints.gridy = 5
        valueConstraints.gridy = 5
        panel.add(JLabel("Confirm:"), constraints)
        confirmOnRestoreCheckBox = JCheckBox("Show confirmation dialog before restoring")
        panel.add(confirmOnRestoreCheckBox, valueConstraints)
        
        // Spacer
        constraints.gridy = 6
        constraints.weighty = 1.0
        constraints.fill = GridBagConstraints.BOTH
        panel.add(JPanel(), constraints)
        
        // Load current values
        loadSettings()
        
        mainPanel = panel
        return panel
    }
    
    private fun loadSettings() {
        pythonPathField?.text = settings.pythonPath
        coreModulePathField?.text = settings.coreModulePath
        autoSaveCheckBox?.isSelected = settings.autoSave
        autoRestoreCheckBox?.isSelected = settings.autoRestore
        confirmOnRestoreCheckBox?.isSelected = settings.confirmOnRestore
    }
    
    override fun isModified(): Boolean {
        return pythonPathField?.text != settings.pythonPath ||
               coreModulePathField?.text != settings.coreModulePath ||
               autoSaveCheckBox?.isSelected != settings.autoSave ||
               autoRestoreCheckBox?.isSelected != settings.autoRestore ||
               confirmOnRestoreCheckBox?.isSelected != settings.confirmOnRestore
    }
    
    override fun apply() {
        settings.pythonPath = pythonPathField?.text ?: "/usr/bin/python3"
        settings.coreModulePath = coreModulePathField?.text ?: ""
        settings.autoSave = autoSaveCheckBox?.isSelected ?: true
        settings.autoRestore = autoRestoreCheckBox?.isSelected ?: false
        settings.confirmOnRestore = confirmOnRestoreCheckBox?.isSelected ?: true
        
        // Update service
        service.configure(settings.pythonPath, settings.coreModulePath)
    }
    
    override fun reset() {
        loadSettings()
    }
}
