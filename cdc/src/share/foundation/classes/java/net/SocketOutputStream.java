/*
 * @(#)SocketOutputStream.java	1.25 06/10/10
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

package java.net;

import java.io.FileDescriptor;
import java.io.FileOutputStream;
import java.io.IOException;

/**
 * This stream extends FileOutputStream to implement a
 * SocketOutputStream. Note that this class should <b>NOT</b> be
 * public.
 *
 * @version     1.17, 02/02/00
 * @author 	Jonathan Payne
 * @author	Arthur van Hoff
 */
class SocketOutputStream extends FileOutputStream
{
    static {
        init();
    }

    private PlainSocketImpl impl = null;
    private byte temp[] = new byte[1];
    private Socket socket = null;
    
    /**
     * Creates a new SocketOutputStream. Can only be called
     * by a Socket. This method needs to hang on to the owner Socket so
     * that the fd will not be closed.
     * @param impl the socket output stream inplemented
     */
    SocketOutputStream(PlainSocketImpl impl) throws IOException {
	super(impl.getFileDescriptor());
	this.impl = impl;
	socket = impl.getSocket();
    }

    /**
     * Returns the unique {@link java.nio.channels.FileChannel FileChannel}
     * object associated with this file output stream. </p>
     *
     * The <code>getChannel</code> method of <code>SocketOutputStream</code>
     * returns <code>null</code> since it is a socket based stream.</p>
     *
     * @return  the file channel associated with this file output stream
     *
     * @since 1.4
     * @spec JSR-51
     */
    /* NOTE: No NIO in CDC
    public final FileChannel getChannel() {
        return null;
    }
    */
    /**
     * Writes to the socket.
     * @param fd the FileDescriptor
     * @param b the data to be written
     * @param off the start offset in the data
     * @param len the number of bytes that are written
     * @exception IOException If an I/O error has occurred.
     */
    private native void socketWrite0(FileDescriptor fd, byte[] b, int off,
				     int len) throws IOException;

    /**
     * Writes to the socket with appropriate locking of the 
     * FileDescriptor.
     * @param b the data to be written
     * @param off the start offset in the data
     * @param len the number of bytes that are written
     * @exception IOException If an I/O error has occurred.
     */
    private void socketWrite(byte b[], int off, int len) throws IOException {

	if (len <= 0 || off < 0 | off + len > b.length) {
	    if (len == 0) {
		return;
	    }
	    throw new ArrayIndexOutOfBoundsException();
	}

	FileDescriptor fd = impl.acquireFD();
	try {
	    socketWrite0(fd, b, off, len);
	} catch (SocketException se) {
	    if (se instanceof sun.net.ConnectionResetException) {
		impl.setConnectionResetPending();
		se = new SocketException("Connection reset");
	    }
	    if (impl.isClosedOrPending()) {
                throw new SocketException("Socket closed");
            } else {
		throw se;
	    }
	} finally {
	    impl.releaseFD();
	}
    }

    /** 
     * Writes a byte to the socket. 
     * @param b the data to be written
     * @exception IOException If an I/O error has occurred. 
     */
    public void write(int b) throws IOException {
	temp[0] = (byte)b;
	socketWrite(temp, 0, 1);
    }

    /** 
     * Writes the contents of the buffer <i>b</i> to the socket.
     * @param b the data to be written
     * @exception SocketException If an I/O error has occurred. 
     */
    public void write(byte b[]) throws IOException {
	socketWrite(b, 0, b.length);
    }

    /** 
     * Writes <i>length</i> bytes from buffer <i>b</i> starting at 
     * offset <i>len</i>.
     * @param b the data to be written
     * @param off the start offset in the data
     * @param len the number of bytes that are written
     * @exception SocketException If an I/O error has occurred.
     */
    public void write(byte b[], int off, int len) throws IOException {
	socketWrite(b, off, len);
    }

    /**
     * Closes the stream.
     */
    private boolean closing = false;
    public void close() throws IOException {
	// Prevent recursion. See BugId 4484411
	if (closing)
	    return;
	closing = true;
	if (socket != null) {
	    if (!socket.isClosed())
		socket.close();
	} else
	    impl.close();
	closing = false;
    }

    /** 
     * Overrides finalize, the fd is closed by the Socket.
     */
    protected void finalize() {}

    /**
     * Perform class load-time initializations.
     */
    private native static void init();

}
