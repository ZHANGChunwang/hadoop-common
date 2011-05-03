<%@ page contentType="text/html;charset=UTF-8"
  import="java.util.*"
  import="org.apache.hadoop.conf.Configuration"
  import="org.apache.hadoop.util.StringUtils"
  import="org.apache.hadoop.hbase.util.Bytes"
  import="org.apache.hadoop.hbase.util.JvmVersion"
  import="org.apache.hadoop.hbase.util.FSUtils"
  import="org.apache.hadoop.hbase.master.HMaster"
  import="org.apache.hadoop.hbase.HConstants"
  import="org.apache.hadoop.hbase.ServerName"
  import="org.apache.hadoop.hbase.HServerLoad"
  import="org.apache.hadoop.hbase.client.HBaseAdmin"
  import="org.apache.hadoop.hbase.client.HConnectionManager"
  import="org.apache.hadoop.hbase.HTableDescriptor" %><%
  HMaster master = (HMaster)getServletContext().getAttribute(HMaster.MASTER);
  Configuration conf = master.getConfiguration();
  ServerName rootLocation = master.getCatalogTracker().getRootLocation();
  boolean metaOnline = master.getCatalogTracker().getMetaLocation() != null;
  List<ServerName> servers = master.getServerManager().getOnlineServersList();
  int interval = conf.getInt("hbase.regionserver.msginterval", 1000)/1000;
  if (interval == 0) {
      interval = 1;
  }
  boolean showFragmentation = conf.getBoolean("hbase.master.ui.fragmentation.enabled", false);
  Map<String, Integer> frags = null;
  if (showFragmentation) {
      frags = FSUtils.getTableFragmentation(master);
  }
%><?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
<html xmlns="http://www.w3.org/1999/xhtml">
<head><meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
<title>HBase Master: <%= master.getServerName().getHostAndPort() %></title>
<link rel="stylesheet" type="text/css" href="/static/hbase.css" />
</head>
<body>
<a id="logo" href="http://wiki.apache.org/lucene-hadoop/Hbase"><img src="/static/hbase_logo_med.gif" alt="HBase Logo" title="HBase Logo" /></a>
<h1 id="page_title">Master: <%=master.getServerName().getHostname()%>:<%=master.getServerName().getPort()%></h1>
<p id="links_menu"><a href="/logs/">Local logs</a>, <a href="/stacks">Thread Dump</a>, <a href="/logLevel">Log Level</a></p>

<!-- Various warnings that cluster admins should be aware of -->
<% if (JvmVersion.isBadJvmVersion()) { %>
  <div class="warning">
  Your current JVM version <%= System.getProperty("java.version") %> is known to be
  unstable with HBase. Please see the
  <a href="http://wiki.apache.org/hadoop/Hbase/Troubleshooting#A18">HBase wiki</a>
  for details.
  </div>
<% } %>
<% if (!FSUtils.isAppendSupported(conf) && FSUtils.isHDFS(conf)) { %>
  <div class="warning">
  You are currently running the HMaster without HDFS append support enabled.
  This may result in data loss.
  Please see the <a href="http://wiki.apache.org/hadoop/Hbase/HdfsSyncSupport">HBase wiki</a>
  for details.
  </div>
<% } %>

<hr id="head_rule" />

<h2>Master Attributes</h2>
<table>
<tr><th>Attribute Name</th><th>Value</th><th>Description</th></tr>
<tr><td>HBase Version</td><td><%= org.apache.hadoop.hbase.util.VersionInfo.getVersion() %>, r<%= org.apache.hadoop.hbase.util.VersionInfo.getRevision() %></td><td>HBase version and svn revision</td></tr>
<tr><td>HBase Compiled</td><td><%= org.apache.hadoop.hbase.util.VersionInfo.getDate() %>, <%= org.apache.hadoop.hbase.util.VersionInfo.getUser() %></td><td>When HBase version was compiled and by whom</td></tr>
<tr><td>Hadoop Version</td><td><%= org.apache.hadoop.util.VersionInfo.getVersion() %>, r<%= org.apache.hadoop.util.VersionInfo.getRevision() %></td><td>Hadoop version and svn revision</td></tr>
<tr><td>Hadoop Compiled</td><td><%= org.apache.hadoop.util.VersionInfo.getDate() %>, <%= org.apache.hadoop.util.VersionInfo.getUser() %></td><td>When Hadoop version was compiled and by whom</td></tr>
<tr><td>HBase Root Directory</td><td><%= FSUtils.getRootDir(master.getConfiguration()).toString() %></td><td>Location of HBase home directory</td></tr>
<tr><td>HBase Cluster ID</td><td><%= master.getClusterId() != null ? master.getClusterId() : "Not set" %><td>Unique identifier generated for each HBase cluster</td></tr>
<tr><td>Load average</td><td><%= StringUtils.limitDecimalTo2(master.getServerManager().getAverageLoad()) %></td><td>Average number of regions per regionserver. Naive computation.</td></tr>
<%  if (showFragmentation) { %>
        <tr><td>Fragmentation</td><td><%= frags.get("-TOTAL-") != null ? frags.get("-TOTAL-").intValue() + "%" : "n/a" %></td><td>Overall fragmentation of all tables, including .META. and -ROOT-.</td></tr>
<%  } %>
<tr><td>Zookeeper Quorum</td><td><%= master.getZooKeeperWatcher().getQuorum() %></td><td>Addresses of all registered ZK servers. For more, see <a href="/zk.jsp">zk dump</a>.</td></tr>
</table>

<h2>Catalog Tables</h2>
<% 
  if (rootLocation != null) { %>
<table>
<tr>
    <th>Table</th>
<%  if (showFragmentation) { %>
        <th title="Fragmentation - Will be 0% after a major compaction and fluctuate during normal usage.">Frag.</th>
<%  } %>
    <th>Description</th>
</tr>
<tr>
    <td><a href="table.jsp?name=<%= Bytes.toString(HConstants.ROOT_TABLE_NAME) %>"><%= Bytes.toString(HConstants.ROOT_TABLE_NAME) %></a></td>
<%  if (showFragmentation) { %>
        <td align="center"><%= frags.get("-ROOT-") != null ? frags.get("-ROOT-").intValue() + "%" : "n/a" %></td>
<%  } %>
    <td>The -ROOT- table holds references to all .META. regions.</td>
</tr>
<%
    if (metaOnline) { %>
<tr>
    <td><a href="table.jsp?name=<%= Bytes.toString(HConstants.META_TABLE_NAME) %>"><%= Bytes.toString(HConstants.META_TABLE_NAME) %></a></td>
<%  if (showFragmentation) { %>
        <td align="center"><%= frags.get(".META.") != null ? frags.get(".META.").intValue() + "%" : "n/a" %></td>
<%  } %>
    <td>The .META. table holds references to all User Table regions</td>
</tr>
  
<%  } %>
</table>
<%} %>

<h2>User Tables</h2>
<%
   HBaseAdmin hba = new HBaseAdmin(conf);
   HTableDescriptor[] tables = hba.listTables();
   HConnectionManager.deleteConnection(hba.getConfiguration(), false);
   if(tables != null && tables.length > 0) { %>
<table>
<tr>
    <th>Table</th>
<%  if (showFragmentation) { %>
        <th title="Fragmentation - Will be 0% after a major compaction and fluctuate during normal usage.">Frag.</th>
<%  } %>
    <th>Description</th>
</tr>
<%   for(HTableDescriptor htDesc : tables ) { %>
<tr>
    <td><a href=table.jsp?name=<%= htDesc.getNameAsString() %>><%= htDesc.getNameAsString() %></a> </td>
<%  if (showFragmentation) { %>
        <td align="center"><%= frags.get(htDesc.getNameAsString()) != null ? frags.get(htDesc.getNameAsString()).intValue() + "%" : "n/a" %></td>
<%  } %>
    <td><%= htDesc.toString() %></td>
</tr>
<%   }  %>

<p> <%= tables.length %> table(s) in set.</p>
</table>
<% } %>

<h2>Region Servers</h2>
<% if (servers != null && servers.size() > 0) { %>
<%   int totalRegions = 0;
     int totalRequests = 0; 
%>

<table>
<tr><th rowspan="<%= servers.size() + 1%>"></th><th>Address</th><th>Start Code</th><th>Load</th></tr>
<%   ServerName [] serverNames = servers.toArray(new ServerName[servers.size()]);
     Arrays.sort(serverNames);
     for (ServerName serverName: serverNames) {
       // HARDCODED FOR NOW; FIX -- READ FROM ZK
       String hostname = serverName.getHostname() + ":60020";
       String url = "http://" + hostname + "/";
       HServerLoad hsl = master.getServerManager().getLoad(serverName);
       String loadStr = hsl == null? "-": hsl.toString();
       if (hsl != null) {
         totalRegions += hsl.getNumberOfRegions();
         totalRequests += hsl.getNumberOfRequests();
       }
       long startCode = serverName.getStartcode();
%>
<tr><td><a href="<%= url %>"><%= hostname %></a></td><td><%= startCode %><%= serverName %></td><td><%= loadStr %></td></tr>
<%   } %>
<tr><th>Total: </th><td>servers: <%= servers.size() %></td><td>&nbsp;</td><td>requests=<%= totalRequests %>, regions=<%= totalRegions %></td></tr>
</table>

<p>Load is requests per second and count of regions loaded</p>
<% } %>
</body>
</html>