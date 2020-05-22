package com.longsai.provider.compete.sharding;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;

import org.apache.shardingsphere.api.sharding.complex.ComplexKeysShardingAlgorithm;
import org.apache.shardingsphere.api.sharding.complex.ComplexKeysShardingValue;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.alibaba.fastjson.JSONObject;
import com.longsai.common.constants.CommConstants;

/**
 * 用户第三方表复杂分片(thirdOpenId哈希取值分片) UserThirdComplexShardingAlgorithm
 * @author wei.yong
 */
public class UserThirdComplexShardingAlgorithm implements ComplexKeysShardingAlgorithm<String> {

	protected final Logger logger = LoggerFactory.getLogger(this.getClass());

    /**
     * 分片
     */
	@Override
	public Collection<String> doSharding(Collection<String> availableTargetNames, ComplexKeysShardingValue<String> shardingValue) {
		logger.info("collection:{}, shardingValue:{}", JSONObject.toJSONString(availableTargetNames), JSONObject.toJSONString(shardingValue));
		Integer size = availableTargetNames.size();
        List<String> tables = getTables(shardingValue, size);
        logger.info("tables:{}", tables);
        return tables;
	}

	/**
	 * 获取表
	 * @param shardingValue
	 * @param size
	 * @return List<String>
	 */
	private List<String> getTables(ComplexKeysShardingValue<String> shardingValue, Integer size) {
        List<String> tables = new ArrayList<String>();
        Map<String, Collection<String>> columnNameAndShardingValuesMap = shardingValue.getColumnNameAndShardingValuesMap();
        if(columnNameAndShardingValuesMap != null && !columnNameAndShardingValuesMap.isEmpty()) {
        	for(Map.Entry<String, Collection<String>> entry : columnNameAndShardingValuesMap.entrySet()){
        	    Collection<String> mapValue = entry.getValue();
        	    for (String value : mapValue) {
        	    	logger.info("hashCode:{}", value.hashCode() & Integer.MAX_VALUE);
        	    	tables.add(shardingValue.getLogicTableName()+CommConstants.UNDERLINE+(value.hashCode() & Integer.MAX_VALUE) % size);
				}
        	}
        }
        return tables;
    }

}