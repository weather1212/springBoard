<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>게시글 작성</title>
<%@ include file="../include/header.jsp"%>
<%@ include file="../include/sessionCheck.jsp"%>
<script>
	$(document).ready(function() {
		$("#btnSave").click(function() {
			//var title = document.form1.title.value; ==> name속성으로 처리할 경우
			//var content = document.form1.content.value;
			//var writer = document.form1.writer.value;
			var title = $("#title").val();
			var content = $("#content").val();
			var writer = $("#writer").val();
			if (title == "") {
				alert("제목을 입력하세요");
				document.form1.title.focus();
				return;
			}
			if (content == "") {
				alert("내용을 입력하세요");
				document.form1.content.focus();
				return;
			}
			/* if (writer == "") {
				alert("이름을 입력하세요");
				document.form1.writer.focus();
				return;
			} */
			// 폼에 입력한 데이터를 서버로 전송
			document.form1.submit();
		});
		$("#btnList").click(function() {
			if (confirm("게시글 목록으로 돌아가시겠습니다까?")) {
				location.href = "${path}/board/list?curPage${curPage}&searchOption=${serchOption}&keyword=${keyword}";
			}
		});
		
		//===========================파일 업로드==============================
		// 파일 업로드 영역에 텍스트 파일 또는 이미지파일을 드래그했을 때 내용이 바로 보여지는 기본 효과 막음
		// dragenter : 마우스가 대상 객체의 위로 처음 진입할 때 발생
		// dragover : 드래그하면서 마우스가 대상 객체의 위에 자리 잡고 있을 때 발생
		$(".fileDrop").on("dragenter dragover", function(event) {
			event.preventDefault(); // 기본 효과를 막음
		});

		// event: jQuery의 이벤트
		// originalEvent: javascript의 이벤트
		$(".fileDrop").on("drop", function(event) {
			event.preventDefault(); // 기본 효과를 막음
			// 드래그된 파일의 정보
			var files = event.originalEvent.dataTransfer.files;
			// 첫번째 파일
			var file = files[0];
			// 콘솔에서 파일정보 확인
			console.log(file);

			// ajax로 전달할 폼 객체
			var formData = new FormData();
			// 폼 객체 파일추가, append("변수명", 값)
			formData.append("file", file);

			// file을 전달할 때는 ajax옵션 속성을  type:post, processDdata: false, contentType:false로 설정한다.
			$.ajax({
				type : "post",
				url : "${path}/upload/uploadAjax",
				data : formData,
				dataType : "text",
				// processDdata: true => get 방식, false => post 방식
				processData : false,
				// contentType: true => application/x-www-form-urlencoded,
				//				false => multipart/form-data
				contentType : false,
				success : function(data) {
					console.log(data);
					// 첨부 파일의 정보
					var fileInfo = getFileInfo(data);
					// 하이퍼링크
					var html = "<a href='"+fileInfo.getLink+"'>"+fileInfo.fileName+"</a><br>";
					// hidden 태그 추가
					html += "<input type='hidden' class='file' value='"+fileInfo.fullName+"'>";
					// div에 추가
					$("#uploadedList").append(html);
				}
			});

		});
	});
</script>
<style type="text/css">
/* 첨부파일을 드래그할 영역의 스타일 */
.fileDrop {
	width: 600px;
	height: 70px;
	border: 2px dotted gray;
	background-color: gray;
}
</style>
</head>
<body>
	<%@ include file="../include/menu.jsp"%>
	<h2>POST</h2>
	<form action="${path}/board/writeAction" name="form1" method="post">
		<div>작성자(이름) : ${sessionScope.userName }</div>
		<hr>
		<div>
			제목
			<input name="title" id="title" size="80" placeholder="제목을 입력해주세요">
		</div>
		<br>
		<div>
			<textarea name="content" id="content" rows="20" cols="88" placeholder="내용을 입력해주세요"></textarea>
		</div>
		<div>
			첨부파일 등록
			<!-- 첨부파일 등록 영역 -->
			<div class="fileDrop"></div>
			<!-- 첨부파일의 목록 출력영역 -->
			<div id="uploadedList"></div>
		</div>
		<div style="width: 650px; text-align: center;">
			<button type="button" id="btnSave">확인</button>
			<button type="reset">취소</button>
			<button type="button" id="btnList">목록으로</button>
		</div>
	</form>
</body>
</html>
