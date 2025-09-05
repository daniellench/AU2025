# AutoCAD Layers Not Plotting in Viewport - Troubleshooting Guide

## Problem Description
Layers visible in viewport on screen but not appearing when plotted from paper space layout.

## Quick Diagnostic Questions (Start Here)

**Before troubleshooting, determine:**
1. Do ANY layers plot from this viewport?
2. Do these layers plot from Model Space?
3. Are missing objects specific types (text, lines, hatches)?
4. Does Print Preview show the missing layers?
5. Is this happening in all drawings or just this one?

## Emergency Workaround
If deadline is critical: Create new viewport, copy/paste objects to known working layers, or export affected area as PDF/image and insert as external reference.

## How to Use This Guide
- **Tier 1** covers basic layer properties and plot settings that solve 70-80% of plotting issues
- **Tier 2** addresses common technical problems like viewport settings and system variables  
- **Tier 3** handles intermediate issues like object properties and drawing corruption
- **Tier 4** covers advanced problems like graphics drivers and file format issues
- **Tier 5** includes rare/specialized fixes for stubborn cases

Work through tiers systematically. Most plotting issues resolve in Tier 1-2. Document which solutions work for your specific setup for future reference.

---

## Solution Priority (Most to Least Common)

### **TIER 1: Most Common Issues (Try These First)**

#### 1. Layer Properties Check
- Open **Layer Properties Manager** (LAYER command)
- Verify **Plot column** shows printer icon (not red circle with line)
- Check **VP Freeze column** - layers shouldn't be frozen in current viewport
- Ensure **Freeze column** doesn't show frozen status
- Confirm layers are **On** (not off)

#### 2. Plot Style Problems
- In Layer Properties Manager, check **Plot Style column**
- If using Color Table (CTB): Verify layer colors aren't set to white or Plot=No
- If using Named Styles (STB): Check assigned plot style isn't "Normal_0" or similar
- **Quick test**: Temporarily set all problem layers to plot style "Normal"

#### 3. Viewport-Specific Layer Settings
- Double-click **inside viewport** to activate model space
- Use **VPLAYER** command to check viewport-specific settings
- Verify layers aren't frozen specifically for this viewport

#### 4. Plot Dialog Settings
- In Plot dialog, click **More Options**
- Ensure **"Plot object lineweights"** is checked
- Verify **"Plot with plot styles"** is enabled
- Check **"Plot paperspace last"** setting

### **TIER 2: Common Technical Issues**

#### 5. Viewport Properties
- Select viewport border → Properties
- Set **"Display Locked"** to "No"
- Check **"Shade plot"** setting (try "As Displayed")
- Verify **"Standard Scale"** is appropriate
- Check **Visual Style** setting

#### 6. System Variables
```
PSLTSCALE = 1
MSLTSCALE = 1
VISRETAIN = 1
LWDISPLAY = 1
```

#### 7. Print Preview Test
- Use **Print Preview** to see if layers appear there
- If missing from preview, issue is pre-plot
- If visible in preview but not on paper, issue is printer/driver

#### 8. Scale and Annotation Issues
- Check **CANNOSCALE** setting
- For annotative objects: Use **ANNORESET** command
- Try **REGEN** or **REGENALL** commands
- Match viewport scale to object annotation scales

### **TIER 3: Intermediate Solutions**

#### 9. Object Properties Override
- Select non-plotting objects
- Use **Properties palette** to check individual object plot settings
- Try **SETBYLAYER** command to reset all properties to ByLayer
- Use **MATCHPROP** from working objects to problem objects

#### 10. Drawing Corruption
- Run **AUDIT** command
- Use **RECOVER** on the drawing file
- Try **PURGE** to remove unused elements

#### 11. Alternative Plotting Methods
- Try plotting to **"DWG to PDF.pc3"** instead of current plotter
- Test with different paper sizes
- Use **PUBLISH** command instead of PLOT
- Try **EXPORTPDF** command

#### 12. Viewport Recreation
- Create new viewport and test same layers
- Use **VPCLIP** to check for clipping boundaries
- Try **MVIEW** to recreate viewport from scratch

### **TIER 4: Advanced Troubleshooting**

#### 13. Block and External Reference Issues
- **EXPLODE** blocks containing non-plotting objects (test copy first)
- Check **XLOADCTL** and **VISRETAIN** for Xref settings
- Use **REFEDIT** if objects are in external references

#### 14. Graphics and Display
- Set **GRAPHICSCONFIG** to software mode
- Update graphics card drivers
- Try **3DCONFIG** and disable hardware acceleration

#### 15. File Format Issues
- **WBLOCK** entire drawing to new file
- Save as different DWG version (2018, 2013)
- **DXFOUT** then **DXFIN** to reset file format
- Copy drawing to local drive if on network

### **TIER 5: Rare/Specialized Issues**

#### 16. Memory and Performance
- Restart AutoCAD and Windows
- Close unnecessary applications
- Clear Windows print spooler
- Check available disk space and virtual memory

#### 17. Custom Elements
- Check custom linetypes loading properly
- Verify custom fonts are available
- **FONTALT** and **FONTMAP** settings
- Reset **CUI** customizations

#### 18. Environmental Issues
- Run AutoCAD as Administrator
- Reset AutoCAD to defaults (hold Ctrl+Shift during startup)
- Create new user profile in OPTIONS > Profiles
- Check TEMP folder permissions and space

#### 19. Nuclear Options (Last Resort)
- **FLATTEN** command on all objects
- Screenshot viewport and plot as raster image
- Manually recreate problem objects on new layers
- Start fresh drawing and copy working elements only