<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>게시글 작성</title>
<%@ include file="../include/header.jsp"%>
<script type="text/javascript" src="${path}/resources/js/common.js"></script>
<script>
	$(document).ready(function() {

		// ===============================게시글 관련 ====================================
		// 게시글 삭제
		$("#btnDelete").click(function() {
			var replyCount = ${map.replyCount };
			console.log(replyCount);
			// 댓글의 개수가 0보다 크면 팝업, 함수 종료
			if (replyCount > 0) {
				alert("댓글이 있는 게시물은 삭제할 수 없습니다.")
				return;
			}
			// 댓글의 개수가 0이면 삭제처리
			if (confirm("삭제하시겠습니까?")) {
				document.form1.action = "${path}/board/delete";
				document.form1.submit();
			}
		});

		// 4. 게시글 수정버튼 클릭 이벤트 처리
		$("#btnUpdate").click(function() {
			//var title = document.form1.title.value; ==> name속성으로 처리할 경우
			//var content = document.form1.content.value;
			//var writer = document.form1.writer.value;
			var title = $("#title").val();
			var content = $("#content").val();
			if (title == "") {
				alert("제목을 입력하세요.");
				document.form1.title.focus();
				return;
			}
			if (content == "") {
				alert("내용을 입력하세요.");
				document.form1.content.focus();
				return;
			}
			document.form1.action = "${path}/board/update";
			// 첨부파일 이름을 form에 추가
			var that = $("#form1");
			var str = "";
			// 태그들.each(함수)
			// id가 uploadedList인 태그 내부에 있는 hidden태그들
			$("#fileDrop .file").each(function(i) {
				str += "<input type='hidden' name='files["+i+"]' value='"+$(this).val()+ "'>";
			});
			// form에 hidden태그들을 추가
			$("#form1").append(str);
			// 폼에 입력한 데이터를 서버로 전송
			document.form1.submit();
		});

		// 게시를 목록으로 이동
		$("#btnList").click(function() {
			console.log("curPage=${map.curPage}&searchOption=${map.serchOption}&keyword=${map.keyword}");
			if (confirm("게시글 목록으로 돌아가시겠습니다까?")) {
				location.href = "${path}/board/list?curPage=${map.curPage}&searchOption=${map.serchOption}&keyword=${map.keyword}";
			}
		});

		//===========================파일 업로드==============================

		// 1. 첨부파일 목록 불러오기 함수 호출
		listAttach();

		// 2. 첨부파일 추가 ajax 요청
		// 파일 업로드 영역에 텍스트 파일 또는 이미지파일을 드래그했을 때 내용이 바로 보여지는 기본 효과 막음
		// dragenter : 마우스가 대상 객체의 위로 처음 진입할 때 발생
		// dragover : 드래그하면서 마우스가 대상 객체의 위에 자리 잡고 있을 때 발생
		$("#fileDrop").on("dragenter dragover", function(event) {
			event.preventDefault(); // 기본 효과를 막음
		});

		// event: jQuery의 이벤트
		// originalEvent: javascript의 이벤트
		$("#fileDrop").on("drop", function(event) {
			event.preventDefault(); // 기본 효과를 막음
			// 로그인한 사용자가 작성자일 경우에만 파일첨부 추가 가능
			if(${sessionScope.userId == dto.writer }) {
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
						var html = "<div><a href='"+fileInfo.getDisplayLink+"' target='_blank'>" + fileInfo.fileName + "</a>&nbsp;&nbsp";
						html += "<a href = '#' class='fileDel' data-src='" + this + "'>[삭제]</a>";
						// hidden 태그 추가
						html += "<input type='hidden' class='file' value='"+fileInfo.fullName+"'></div>";
						// div에 추가
						$("#fileDrop").append(html);
					},
					error : function(request, status, error) { //status-상태, error-에러 내용
						console.log("데이터 전송에 실패했습니다. : "+ "status : " + request.status + ", error : " + error);
					}
				});	
			}
		});

		// 3. 첨부파일 삭제 ajax 요청
		// 태그.on("이벤트", "자손태그", 이벤트 핸들러)
		$("#fileDrop").on("click", ".fileDel", function(event) {
			var that = $(this); //클릭한 a태그
			$.ajax({
				type : "post",
				url : "${path}/upload/deleteFile",
				// data: "fileName=" + $(this).attr("data-src") = {fileName:$(this).attr("data-src")}
				data : {fileName : $(this).attr("data-src")},
				dataType : "text",
				success : function(result) {
					if (result == "deleted") {
						that.parent("div").remove();
					}
				}
			});
		});

		// ==================댓글 관련 ===========================
		// 댓글 목록
		// 		listReply("1");	// **forwarding 방식
		// 		listReply2();	// **json 리턴 방식
		listReplyRest("1"); // **Rest 방식

		// **댓글 쓰기
		$("#btnReply").click(function() {
			//reply();		// 파라미터로 입력
			replyJson(); // json으로 입력
		});
	});

	// **댓글 쓰기========================================
	// 파라미터 전달 방식 댓글쓰기
	function reply() {
		var replytext = $("#replytext").val();
		var bno = "${dto.bno}"
		// **비밀댓글 체크 여부
		var secretReply = 'n';
		// 태그.is(":속성") 태그에 해당 속성이 있는지 boolean반환
		if ($("#secretReply").is(":checked")) { //체크 여부
			secretReply = 'y';
		}
		//alert(secretReply);
		// **비밀댓글 파라미터 추가
		var param = "replytext=" + replytext + "&bno=" + bno + "&secretReply="
				+ secretReply; //ajax를 통해 보낼 데이터
		$.ajax({
			type : "post",
			url : "${path}/reply/write",
			data : param,
			success : function() {
				alert("댓글이 등록되었습니다.")
				// **추가된 댓글 목록 ajax요청
				listReply("1"); // forward(@Controller)
				// 				listReply2();	// json 리턴(@ReseteController)
			},
			error : function() {
				console.log("데이터 전송에 실패했습니다.");
			}

		});
	}
	// **json 방식 댓글 쓰기
	function replyJson() {
		var replytext = $("#replytext").val();
		var bno = "${dto.bno}"
		// **비밀댓글 체크 여부
		var secretReply = 'n';
		// 태그.is(":속성") 태그에 해당 속성이 있는지 boolean반환
		if ($("#secretReply").is(":checked")) { //체크 여부
			secretReply = 'y';
		}
		//alert(secretReply);
		$.ajax({
			type : "post",
			url : "${path}/reply/writeRest",
			contentType : "application/json",
			dataType : "text",
			data : JSON.stringify({
				bno : bno,
				replytext : replytext,
				secretReply : secretReply
			}),
			success : function(msg) {
				alert("댓글이 등록되었습니다.")
				console.log("ajax success: " + msg);
				// **추가된 댓글 목록 ajax요청
				// 				listReply("1");		// forward(@Controller)
				// 				listReply2();		// json 리턴(@ReseteController)
				listReplyRest("1"); // Rest 방식
			},
			error : function(request, status, error) { //status-상태, error-에러 내용
				console.log("데이터 전송에 실패했습니다. : " + "status : " + request.status
						+ ", error : " + error);
			}

		});
	}

	// **댓글목록========================================
	// @Controller 방식(파라미터 전달)
	function listReply(num) {
		console.log(num);
		$.ajax({
			type : "get",
			url : "${path}/reply/list?bno=${dto.bno}&curPage=" + num,
			success : function(result) {
				// responseText가 result에 저장됨
				$("#listReply").html(result);
			},
			error : function() {
				console.log("댓글 목록을 불러오지 못했습니다.");
			}

		});
	}
	// @RestController 방식 (json)
	function listReply2() {
		$.ajax({
			type : "get",
			// contentType: "application/json", ==> RestController이기 때문에 생략가능
			url : "${path}/reply/listJson?bno=${dto.bno}",
			success : function(result) {
				console.log(result);
				var printout = "(RestController 방식)<table>";
				for ( var i in result) {
					printout += "<tr>";
					printout += "<td><br>" + result[i].userName;
					printout += "(" + changeDate(result[i].regdate) + ")<br>";
					printout += result[i].replytext + "</td>";
					printout += "<tr>";
				}
				printout += "</table>";
				$("#listReply").html(printout);
			},
			error : function() {
				console.log("댓글 목록을 불러오지 못했습니다.");
			}
		});

	}
	// **날짜 변환 함수 작성
	function changeDate(date) {
		date = new Date(parseInt(date));
		year = date.getFullYear();
		month = date.getMonth();
		day = date.getDate();
		hour = date.getHours();
		minute = date.getMinutes();
		second = date.getSeconds();
		strDate = year + "-" + month + "-" + day + "-" + hour + ":" + minute + ":" + second;

		return strDate;
	}

	// **댓글 목록 - Rest 방식 ====================================
	function listReplyRest(num) {
		$.ajax({
			type : "get",
			url : "${path}/reply/list/${dto.bno}/" + num,
			success : function(result) {
				// 				console.log("댓글 목록 ajax 성공 : " + result);
				//responseText가 result에 저장됨
				$("#listReply").html(result);
			},
			error : function(request, status, error) { //status-상태, error-에러 내용
				console.log("댓글 목록 불러오기에 실패했습니다. : " + "status : "
						+ request.status + ", error : " + error);
			}
		});
	}
	// **댓글 수정 화면 생성 함수
	function showReplyModify(rno) {
		$.ajax({
			type : "get",
			url : "${path}/reply/detail/" + rno,
			success : function(result) {
				$("#modifyReply").html(result);
				// 태그.css("속성", "값")
				$("#modifyReply").css("visibility", "visible");
			}
		});
	}

	//================첨부파일 관련=================================
	// 첨부파일 목록 ajax요청 처리
	// $(객체) $("태그") $("#id") $(".class")
	function listAttach() {
		// 로그 출력
		console.log("listAttach 실행");
		$.ajax({
			type : "post",
			url : "${path}/board/getAttach/${dto.bno}",
			success : function(list) {
				console.log(list);
				$(list).each(function() {
					// each문 내부의 this : 각 step에 해당되는 값을 의미
					var fileInfo = getFileInfo(this);
					// a태그안에는 파일의 링크를 걸어주고, 목록에는 파일의 이름을 출력
					var html = "<div><a href='" + fileInfo.getDisplayLink + "' target='_blank'>" + fileInfo.fileName + "</a>&nbsp;&nbsp;";
					// ***로그인한 회원이 작성자일 경우 삭제 버튼
					if(${sessionScope.userId == dto.writer }) {
						html += "<a href = '#' class='fileDel' data-src='" + this + "'>[삭제]</a></div>";
					}
					$("#fileDrop").append(html);
				});
			},
			error : function(request, status, error) { //status-상태, error-에러 내용
				console.log("첨부파일 목록 불러오기에 실패했습니다. : " + "status : " + request.status + ", error : " + error);
			}
		});
	}
</script>
<style type="text/css">
#modifyReply {
	width: 600px;
	height: 130px;
	background-color: #90909050;
	padding: 10px;
	z-index: 10px;
	visibility: hidden;
}

#fileDrop {
	width: 600px;
	height:auto;
	padding: 10px 0px; 
	border: 1px dotted gray;
}
</style>
</head>
<body>
	<%@ include file="../include/menu.jsp"%>
	<h2>BOARD</h2>
	<c:choose>
		<c:when test="${dto.show == 'y' }">
			<!-- show가 y일 때  (게시글 삭제상태x)-->
			<!-- 게시물 상세보기 영역 -->
			<form name="form1" id="form1" method="post">
				<div>
					<!-- 원하는 날짜형식으로 출력하기 위해 fmt태그 사용 -->
					작성일자 :
					<fmt:formatDate value="${dto.regdate}" pattern="yyyy-MM-dd a HH:mm:ss" />
					<!-- 날짜 형식 => yyyy 4자리연도, MM 월, dd 일, a 오전/오후, HH 24시간제, hh 12시간제, mm 분, ss 초 -->
				</div>
				<div>조회수 : ${dto.viewcnt}</div>
				<div>
					작성자(이름)
					<%--  <input name="writer" id="writer" value="${dto.writer}"
				placeholder="이름을 입력해주세요"> --%>
					${dto.userName }
				</div>
				<hr>
				<div>
					제목
					<input name="title" id="title" size="80" value="${dto.title}"
						placeholder="제목을 입력해주세요"
					>
				</div>
				<br>
				<div>
					<textarea name="content" id="content" rows="20" cols="88" placeholder="내용을 입력해주세요">${dto.content}</textarea>
				</div>
				<!-- 첨부파일 목록 -->
				<div>
					첨부파일
					<div id="uploadedList"></div>
				</div>
				<!-- 첨부파일을 드래그할 영역 -->
				<div>
					<div id="fileDrop"></div>
				</div>
				<br>
				<div style="width: 650px; text-align: center;">
					<!-- 게시물번호를 hidden으로 처리 -->
					<input type="hidden" name="bno" value="${dto.bno}">
					<input type="hidden" name="writer" value="${dto.writer}">
					<c:if test="${sessionScope.userId == dto.writer }">
						<button type="button" id="btnUpdate">수정</button>
						<button type="button" id="btnDelete">삭제</button>
					</c:if>
					<button type="button" id="btnList">목록으로</button>
				</div>
			</form>

			<!-- 댓글 섹션 -->
			<div style="width: 650px;">
				<br>
				<!-- **로그인한 화원에게만 댓글 작성 폼이 보이게 처리 -->
				<c:if test="${sessionScope.userId != null }">
					<hr>
					<textarea rows="5" cols="50" id="replytext" placeholder="comment here!"></textarea>
					<br>
					<!-- **비밀댓글 체크 박스 -->
					<input type="checkbox" id="secretReply">비밀 댓글
					<button type="button" id="btnReply">댓글 달기</button>
					<hr>
				</c:if>
			</div>
		</c:when>
		<c:otherwise>
			<!--show가 n일 때(게시글 삭제상태) -->
			삭제된 게시글입니다.
		</c:otherwise>
	</c:choose>
	<!-- 댓글 목록을 출력할 위치 -->
	<div id="listReply"></div>
</body>
</html>
