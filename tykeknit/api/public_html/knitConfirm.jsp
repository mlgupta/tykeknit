<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic"%>

<logic:equal name="knitConfirmForm" property="rc" value="0" >
   <meta http-equiv="REFRESH" content="0;url=http://www.tykeknit.com/request_accept.htm">
</logic:equal>

<logic:equal name="knitConfirmForm" property="rc" value="-1" >
   <meta http-equiv="REFRESH" content="0;url=http://www.tykeknit.com/request_error.htm">
</logic:equal>

<logic:equal name="knitConfirmForm" property="rc" value="-100" >
   <meta http-equiv="REFRESH" content="0;url=http://www.tykeknit.com/request_error.htm">
</logic:equal>

