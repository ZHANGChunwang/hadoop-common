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
package org.apache.hadoop.hdfs.server.protocolR23Compatible;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

import org.apache.hadoop.classification.InterfaceAudience;
import org.apache.hadoop.classification.InterfaceStability;
import org.apache.hadoop.io.Writable;

/**
 * Base class for a server command.
 * Issued by the name-node to notify other servers what should be done.
 * Commands are defined by actions defined in respective protocols.
 */
@InterfaceAudience.Private
@InterfaceStability.Evolving
public abstract class ServerCommandWritable implements Writable {
  private int action;

  /**
   * Unknown server command constructor.
   * Creates a command with action 0.
   */
  public ServerCommandWritable() {
    this(0);
  }

  /**
   * Create a command for the specified action.
   * Actions are protocol specific.
   * @param action
   */
  public ServerCommandWritable(int action) {
    this.action = action;
  }

  /**
   * Get server command action.
   * @return action code.
   */
  public int getAction() {
    return this.action;
  }

  ///////////////////////////////////////////
  // Writable
  ///////////////////////////////////////////
  @Override
  public void write(DataOutput out) throws IOException {
    out.writeInt(this.action);
  }

  @Override
  public void readFields(DataInput in) throws IOException {
    this.action = in.readInt();
  }
}
