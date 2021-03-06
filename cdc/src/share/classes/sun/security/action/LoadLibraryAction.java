/*
 * @(#)LoadLibraryAction.java	1.13 06/10/10
 *
 * Copyright  1990-2008 Sun Microsystems, Inc. All Rights Reserved.  
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER  
 *   
 * This program is free software; you can redistribute it and/or  
 * modify it under the terms of the GNU General Public License version  
 * 2 only, as published by the Free Software Foundation.   
 *   
 * This program is distributed in the hope that it will be useful, but  
 * WITHOUT ANY WARRANTY; without even the implied warranty of  
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU  
 * General Public License version 2 for more details (a copy is  
 * included at /legal/license.txt).   
 *   
 * You should have received a copy of the GNU General Public License  
 * version 2 along with this work; if not, write to the Free Software  
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  
 * 02110-1301 USA   
 *   
 * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa  
 * Clara, CA 95054 or visit www.sun.com if you need additional  
 * information or have any questions. 
 *
 */

package sun.security.action;

/**
 * A convenience class for loading a system library as a privileged action.
 *
 * <p>An instance of this class can be used as the argument of
 * <code>AccessController.doPrivileged</code>.
 *
 * <p>The following code attempts to load the system library named
 * <code>"lib"</code> as a privileged action: <p>
 *
 * <pre>
 * java.security.AccessController.doPrivileged(new LoadLibraryAction("lib"));
 * </pre>
 *
 * @author Roland Schemers
 * @version 1.6, 02/02/00
 * @see java.security.PrivilegedAction
 * @see java.security.AccessController
 * @since JDK1.2
 */

public class LoadLibraryAction implements java.security.PrivilegedAction {
    private String theLib;

    /**
     * Constructor that takes the name of the system library that needs to be
     * loaded.
     *
     * <p>The manner in which a library name is mapped to the
     * actual system library is system dependent.
     *
     * @param theLib the name of the library.
     */
    public LoadLibraryAction(String theLib) {
	this.theLib = theLib;
    }

    /**
     * Loads the system library whose name was specified in the constructor.
     */
    public Object run() {
	System.loadLibrary(theLib);
	return null;
    }
}
