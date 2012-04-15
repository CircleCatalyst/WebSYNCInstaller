/**
 * WebSYNC Client Copyright 2007, 2008 Dataview Ltd
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software 
 * Foundation, either version 3 of the License, or (at your option) any later 
 * version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 * 
 * A copy of the GNU General Public License version 3 is included with this 
 * source distribution. Alternatively this licence can be viewed at 
 * <http://www.gnu.org/licenses/>
 */
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Properties;

/**
 * A simple class used to configure the system and application properties
 * of WebSYNCClient on installation.
 * Designed to be run as part of the installation procedure.
 * Must be run AFTER the installation directory is created and all relevant
 * binaries and files have been created.
 * i.e. should be run just before starting the service.
 * Exits with a non-zero code if an error occurred.
 *
 * @author	William Song
 * @version	1.0.0
 */
public class Configure {
    
    /**
     * The main method.
     *
     * @param	args	the command line arguments
     */
    public static void main(String[] args) {
    	// expecting the installation dir in args[0]
    	if (args == null || args.length < 1) {
    		System.err.println("Usage: java Configure <install_dir>");
    		System.exit(1);
    	}
    	
    	String installDirString = args[0];
    	
    	File installDir = new File(installDirString);
    	if (!installDir.isDirectory()) {
    		System.err.println(installDirString + " is not a directory");
    		System.exit(1);
    	}
    	
    	String confDir = installDir.getAbsolutePath() + File.separator + "config" + File.separator;
    	String systemProp = confDir + "system.properties";
    	String appProp = confDir + "websyncclient.properties";
    	String loggerProp = confDir + "logger.properties";
    	//String wrapperProp = confDir + "wrapper.conf";
    	//String guiProp = installDir.getAbsolutePath() + File.separator + "gui" + File.separator + "appconfig.properties";
    	
    	File sysPropFile = new File(systemProp);
    	File appPropFile = new File(appProp);
    	File loggerPropFile = new File(loggerProp);
    	//File wrapperPropFile = new File(wrapperProp);
    	//File guiPropFile = new File(guiProp);
    	
    	Properties systemConfig = new Properties();
    	//Properties appConfig = new Properties();
    	//Properties loggerConfig = new Properties();
    	//Properties wrapperConfig = new Properties();
    	//Properties guiConfig = new Properties();
    	
    	// try and load the properties
    	try {
    		systemConfig.loadFromXML(new FileInputStream(sysPropFile));
    		//appConfig.loadFromXML(new FileInputStream(appPropFile));
    		//loggerConfig.load(new FileInputStream(loggerPropFile));
    		//wrapperConfig.load(new FileInputStream(wrapperPropFile));
    		//guiConfig.load(new FileInputStream(guiPropFile));
    	} catch (FileNotFoundException e) {
    		System.err.println("Failed locate configuration files: " + e);
    		System.exit(1);
    	} catch (Exception e) {
    		System.err.println("Failed to load configuration files: " + e);
    		e.printStackTrace();
    		System.exit(1);
    	}    		
    	
    	try {
    		// configure wrapper properties
    		// -to supply the location of the configuration file as a command line argument
    		//String sysConf = "-Dnz.dataview.websyncclient.sysconf_file=\"" + systemProp + "\"";
    		//wrapperConfig.setProperty("wrapper.java.additional.4", sysConf);
    		
    		// configure gui properties
    		// -set location of main configuration file
    		//guiConfig.setProperty("nz.dataview.websyncclientgui.sysconf_file", systemProp);
    		
    		// configure system properties
    		// -location of the logger.properties file
    		// -location of the websyncclient.properties file
			// -location of the main log file
	    	systemConfig.setProperty("nz.dataview.websyncclient.logconfig_file", loggerPropFile.getAbsolutePath());
	    	systemConfig.setProperty("nz.dataview.websyncclient.appconfig_file", appPropFile.getAbsolutePath());
			String mainLog = installDir.getAbsolutePath() + File.separator + "logs" + File.separator + "main.log";
			systemConfig.setProperty("nz.dataview.websyncclient.main_log_file", mainLog);
	    	
	    	// configure logger properties
	    	// -location of the log file
	    	//String mainLog = "\"" + installDir.getAbsolutePath() + File.separator + "logs" + File.separator + "main.log\"";
	    	//loggerConfig.setProperty("log4j.appender.A1.File", mainLog);
    	} catch (Exception e) {
    		System.err.println("Could not edit configuration: " + e);
    		System.exit(1);
    	}	
    	
    	// try and save the properties
    	try {	
    		systemConfig.storeToXML(new FileOutputStream(sysPropFile), null);
    		//appConfig.storeToXML(new FileOutputStream(appPropFile), null);
    		//loggerConfig.store(new FileOutputStream(loggerPropFile), null);
    		//wrapperConfig.store(new FileOutputStream(wrapperPropFile), null);
    		//guiConfig.store(new FileOutputStream(guiPropFile), null);
    	} catch (FileNotFoundException e) {
    		System.err.println("Failed to lcoate configuration files: " + e);
    		System.exit(1);
    	} catch (Exception e) {
    		System.err.println("Failed to save configuration files: " + e);
    		System.exit(1);
    	}	
    }
}