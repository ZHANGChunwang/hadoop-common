/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.hadoop.hdfs.protocolR23Compatible;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.classification.InterfaceStability;
import org.apache.hadoop.hdfs.DeprecatedUTF8;
import org.apache.hadoop.io.Writable;

/**
 * DatanodeID is composed of the data node 
 * name (hostname:portNumber) and the data storage ID, 
 * which it currently represents.
 * 
 */
@InterfaceAudience.Private
@InterfaceStability.Stable
public class DatanodeIDWritable implements Writable {
  public static final DatanodeIDWritable[] EMPTY_ARRAY = {}; 

  public String name;      /// hostname:portNumber
  public String storageID; /// unique per cluster storageID
  protected int infoPort;     /// the port where the infoserver is running
  public int ipcPort;     /// the port where the ipc server is running

  
  static public DatanodeIDWritable[] 
      convertDatanodeID(org.apache.hadoop.hdfs.protocol.DatanodeID[] did) {
    if (did == null) return null;
    final int len = did.length;
    DatanodeIDWritable[] result = new DatanodeIDWritable[len];
    for (int i = 0; i < len; ++i) {
      result[i] = convertDatanodeID(did[i]);
    }
    return result;
  }
  
  static public org.apache.hadoop.hdfs.protocol.DatanodeID[] 
      convertDatanodeID(DatanodeIDWritable[] did) {
    if (did == null) return null;
    final int len = did.length;
    org.apache.hadoop.hdfs.protocol.DatanodeID[] result = new org.apache.hadoop.hdfs.protocol.DatanodeID[len];
    for (int i = 0; i < len; ++i) {
      result[i] = convertDatanodeID(did[i]);
    }
    return result;
  }
  
  static public org.apache.hadoop.hdfs.protocol.DatanodeID convertDatanodeID(
      DatanodeIDWritable did) {
    if (did == null) return null;
    return new org.apache.hadoop.hdfs.protocol.DatanodeID(
        did.getName(), did.getStorageID(), did.getInfoPort(), did.getIpcPort());
    
  }
  
  public static DatanodeIDWritable convertDatanodeID(org.apache.hadoop.hdfs.protocol.DatanodeID from) {
    return new DatanodeIDWritable(from.getName(),
        from.getStorageID(),
        from.getInfoPort(),
        from.getIpcPort());
  }
  
  /** Equivalent to DatanodeID(""). */
  public DatanodeIDWritable() {this("");}

  /** Equivalent to DatanodeID(nodeName, "", -1, -1). */
  public DatanodeIDWritable(String nodeName) {this(nodeName, "", -1, -1);}

  /**
   * DatanodeID copy constructor
   * 
   * @param from
   */
  public DatanodeIDWritable(DatanodeIDWritable from) {
    this(from.getName(),
        from.getStorageID(),
        from.getInfoPort(),
        from.getIpcPort());
  }
  
  /**
   * Create DatanodeID
   * @param nodeName (hostname:portNumber) 
   * @param storageID data storage ID
   * @param infoPort info server port 
   * @param ipcPort ipc server port
   */
  public DatanodeIDWritable(String nodeName, String storageID,
      int infoPort, int ipcPort) {
    this.name = nodeName;
    this.storageID = storageID;
    this.infoPort = infoPort;
    this.ipcPort = ipcPort;
  }
  
  public void setName(String name) {
    this.name = name;
  }

  public void setInfoPort(int infoPort) {
    this.infoPort = infoPort;
  }
  
  public void setIpcPort(int ipcPort) {
    this.ipcPort = ipcPort;
  }
  
  /**
   * @return hostname:portNumber.
   */
  public String getName() {
    return name;
  }
  
  /**
   * @return data storage ID.
   */
  public String getStorageID() {
    return this.storageID;
  }

  /**
   * @return infoPort (the port at which the HTTP server bound to)
   */
  public int getInfoPort() {
    return infoPort;
  }

  /**
   * @return ipcPort (the port at which the IPC server bound to)
   */
  public int getIpcPort() {
    return ipcPort;
  }

  /**
   * sets the data storage ID.
   */
  public void setStorageID(String storageID) {
    this.storageID = storageID;
  }

  /**
   * @return hostname and no :portNumber.
   */
  public String getHost() {
    int colon = name.indexOf(":");
    if (colon < 0) {
      return name;
    } else {
      return name.substring(0, colon);
    }
  }
  
  public int getPort() {
    int colon = name.indexOf(":");
    if (colon < 0) {
      return 50010; // default port.
    }
    return Integer.parseInt(name.substring(colon+1));
  }

  
  public String toString() {
    return name;
  }    

  /////////////////////////////////////////////////
  // Writable
  /////////////////////////////////////////////////
  @Override
  public void write(DataOutput out) throws IOException {
    DeprecatedUTF8.writeString(out, name);
    DeprecatedUTF8.writeString(out, storageID);
    out.writeShort(infoPort);
  }

  @Override
  public void readFields(DataInput in) throws IOException {
    name = DeprecatedUTF8.readString(in);
    storageID = DeprecatedUTF8.readString(in);
    // the infoPort read could be negative, if the port is a large number (more
    // than 15 bits in storage size (but less than 16 bits).
    // So chop off the first two bytes (and hence the signed bits) before 
    // setting the field.
    this.infoPort = in.readShort() & 0x0000ffff;
  }
}
