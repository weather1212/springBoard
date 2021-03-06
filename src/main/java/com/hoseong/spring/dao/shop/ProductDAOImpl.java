package com.hoseong.spring.dao.shop;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.hoseong.spring.vo.shop.ProductVO;

@Repository
public class ProductDAOImpl implements ProductDAO {

	@Autowired
	SqlSession sqlSession;
	
	// 01. 상품목록
	@Override
	public List<ProductVO> listProduct() {
		return sqlSession.selectList("productMapper.listProduct");
	}

	// 02. 상품상세
	@Override
	public ProductVO detailProduct(int productId) {
		return sqlSession.selectOne("productMapper.detailProduct", productId);
	}

	// 03. 상품수정
	@Override
	public void updateProduct(ProductVO vo) {
		sqlSession.update("productMapper.updateProduct", vo);
	}

	// 04. 상품삭제
	@Override
	public void deleteProduct(int productId) {
		sqlSession.delete("productMapper.deleteProduct", productId);
	}
	
	// 05. 상품 추가
	@Override
	public void insertProduct(ProductVO vo) {
		sqlSession.insert("productMapper.insertProduct", vo);
	}
	
	// 06. 상품이미지 삭제를 위한 이미지파일 정보
	@Override
	public String fileInfo(int productId) {
		return sqlSession.selectOne("productMapper.fileInfo", productId);
	}

}
