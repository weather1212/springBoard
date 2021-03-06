package com.hoseong.spring.service.board;

import java.util.List;

import javax.servlet.http.HttpSession;

import com.hoseong.spring.vo.board.BoardVO;
import com.hoseong.spring.vo.board.ReplyVO;

public interface ReplyService {

	// 댓글 목록
	public List<ReplyVO> list(Integer bno, int start, int end, HttpSession session);

	// 댓글 입력
	public void write(ReplyVO vo);

	// 댓글 수정
	public void update(ReplyVO vo);

	// 댓글 삭제
	public void delete(Integer rno);

	// 댓글 갯수
	public int count(int bno);

	// 댓글 상세보기
	public ReplyVO detail(Integer rno);
}
