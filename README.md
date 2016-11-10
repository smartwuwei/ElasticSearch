0、启停服务：
启动：es-start.sh
#!/bin/sh
JAVA_HOME_DEF="./jdk1.8.0_65"
ES_HOME="./elasticsearch-1.7.3"
export JAVA_HOME=$JAVA_HOME_DEF
sh ./es-stop.sh
echo "start Elasticsearch"
${ES_HOME}/bin/elasticsearch -d
echo "start Deamon"
nohup sh ./es-deamon.sh &

守护进程：es-deamon.sh
#!/bin/sh
JAVA_HOME_DEF="./jdk1.8.0_65"
ES_HOME="./elasticsearch-1.7.3"
LOG_PATH=${ES_HOME}/logs/es-deamon.log
function echoLog(){
message=$1
echo -n $(date "+%Y/%m/%d %T") >> $LOG_PATH
echo " $message" >> $LOG_PATH
}
while true
do
pid=$(jps | grep Elasticsearch | cut -d ' ' -f 1)
if [ "$pid" = "" ]
then
echoLog "Elasticsearch Server was killed!"
export JAVA_HOME=$JAVA_HOME_DEF
${ES_HOME}/bin/elasticsearch -d
echoLog "Elasticsearch Server was restarted!"
fi
sleep 5
done

停止：es-stop.sh
#!/bin/sh
echo "stop Deamon"
dpid=$(ps -ef | grep es-deamon.sh | grep -v grep | sed 's/[ ]\+/ /g' | cut -d ' ' -f 2)
if [ "$dpid" != "" ]
then
echo "kill Deamon pid=$dpid"
kill -9 $dpid
fi
echo "stop Elasticsearch"
pid=$(jps | grep Elasticsearch | cut -d ' ' -f 1)
if [ "$pid" != "" ]
then
echo "kill Elasticsearch pid=$pid"
kill -9 $pid
fi


1、es服务分词测试：
curl 'http://localhost:9200/crm/_analyze?analyzer=ik_max_word&pretty=true' -d '  
{  
"text":"我是中国人呵呵"  
}' 


2、es启动url：
bin/elasticsearch -d -Xmx4g -Xms4g -Des.index.storage.type=memory
http://10.11.0.90:9200/
http://10.11.0.90:9200/_plugin/head/
官网：https://www.elastic.co
river github：https://github.com/jprante/elasticsearch-jdbc


3、本session切换环境变量：
export JAVA_HOME="/home/work/maolei/jdk1.8.0_65"
elasticsearch、plugin两个脚本需要切


4、修改es文件所属work用户：
chown -R work:work elasticsearch.1.7.3


5、IK注入es配置文件config/elasticsearch.yml
index:
   analysis:
     analyzer:
       ik:
         alias: [ik_analyzer]
         type: org.elasticsearch.index.analysis.IkAnalyzerProvider
       ik_max_word:  
         type: ik  
         use_smart: false  
       ik_smart:  
         type: ik  
         use_smart: true

 index.analysis.analyzer.default.type : ik
 
 
 6、IK与es版本匹配：
 ik_1.4.1 --> es_1.7.3 --> jdk1.8.0_65 --> jdbcRiver_1.5.0.5
 

 7、显示当前字符集：
 echo $LANG
 zh_CN.UTF-8
 echo $JAVA_HOME
 /home/work/longzhe/jdk_1.6_45/jdk1.6.0_45
 
 显示当前glibc版本：
 strings /lib64/libc.so.6 |grep GLIBC_
 
 
 8、下载对应的jdbc-river：
 https://github.com/jprante/elasticsearch-jdbc （需要maven编译）
 
 9、下载对应的IK分词器：
 https://github.com/medcl/elasticsearch-analysis-ik （需要maven编译）
 
 10、下载head插件：
 ./plugin install mobz/elasticsearch-head
 
 11、下载es：
 https://www.elastic.co/downloads/elasticsearch
 
 
 12、创建索引：
 "type": "date","format": "dateOptionalTime"：时间戳
 "type": "date","format": "YYYY-MM-dd hh:mm:ss"：标准date
  
游戏攻略：
curl -XPUT 'http://localhost:9200/crm' -d '
{
	"settings": {
		"number_of_shards": 3,
		"number_of_replicas": 1,
		"index.refresh_interval": "300s",
		"index.translog.flush_threshold_ops": "100000",
		"index.store.type": "niofs"
	},
	
	"mappings": {
		"crm_strategy": {
			"_all": {"enabled":true},
			"_source": {"enabled" : true,"compress": true,"excludes" : ["content"]},
			"properties": {
				"id": {
					"type": "Integer",
					"store": false,
					"index": "no"
				},
				"strategy_id": {
					"type": "Integer",
					"store": false,
					"index": "no"
				},
				"game_id": {
					"type": "Integer",
					"store": false,
					"index": "no"
				},
				"app_id": {
					"type": "Integer",
					"store": false,
					"index": "not_analyzed",
					"include_in_all": true
				},
				"title": {
					"type": "String",
					"store": false,
					"index": "analyzed",
					"include_in_all": true,
					"indexAnalyzer": "ik_max_word", 
					"searchAnalyzer": "ik_max_word"
				},
				"icon": {
					"type": "String",
					"store": false,
					"index": "no"
				},
				"strategy_time": {
					"type": "String",
					"store": false,
					"index": "no"
				},
				"author": {
					"type": "String",
					"store": false,
					"index": "no"
				},
				"sort_id": {
					"type": "Integer",
					"store": false,
					"index": "no"
				},
				"sort_name": {
					"type": "String",
					"store": false,
					"index": "no"
				},
				"content": {
					"type": "String",
					"store": false,
					"index": "analyzed",
					"include_in_all": true,
					"indexAnalyzer": "ik_smart", 
					"searchAnalyzer": "ik_smart"
				},
				"is_recommend": {
					"type": "Integer",
					"store": false,
					"index": "no"
				},
				"is_allow_comment": {
					"type": "Integer",
					"store": false,
					"index": "no"
				},
				"data_from": {
					"type": "Integer",
					"store": false,
					"index": "no"
				},
				"status": {
					"type": "Integer",
					"store": false,
					"index": "no"
				},
				"add_time": {
					"type": "String",
					"store": false,
					"index": "no"
				}
			}
		}
	}
}'

游戏搜索外放：
curl -XPUT 'http://localhost:9200/game' -d '
{
	"settings": {
		"number_of_shards": 3,
		"number_of_replicas": 1,
		"index.refresh_interval": "300s",
		"index.translog.flush_threshold_ops": "100000",
		"index.store.type": "niofs"
	},
	
	"mappings": {
		"game_search": {
			"_all": {
				"enabled": true
			},
			"_source": {
				"enabled": true,
				"compress": true
			},
			"properties": {
				"cid": {
					"type": "Integer",
					"store": false,
					"index": "no"
				},
				"appid": {
					"type": "Integer",
					"store": false,
					"index": "no"
				},
				"name": {
					"type": "String",
					"store": false,
					"index": "analyzed",
					"include_in_all": true,
					"indexAnalyzer": "ik_max_word",
					"searchAnalyzer": "ik_max_word"
				},
				"version": {
					"type": "String",
					"store": false,
					"index": "no"
				},
				"icon": {
					"type": "String",
					"store": false,
					"index": "no"
				},
				"desc": {
					"type": "String",
					"store": false,
					"index": "analyzed",
					"include_in_all": true,
					"indexAnalyzer": "ik_smart",
					"searchAnalyzer": "ik_smart"
				},
				"type": {
					"type": "String",
					"store": false,
					"index": "analyzed",
					"include_in_all": true,
					"indexAnalyzer": "ik_max_word",
					"searchAnalyzer": "ik_max_word"
				},
				"level": {
					"type": "String",
					"store": false,
					"index": "no"
				},
				"size": {
					"type": "Integer",
					"store": false,
					"index": "no"
				},
				"image_url1": {
					"type": "String",
					"store": false,
					"index": "no"
				},
				"image_url2": {
					"type": "String",
					"store": false,
					"index": "no"
				},
				"image_url3": {
					"type": "String",
					"store": false,
					"index": "no"
				},
				"image_url4": {
					"type": "String",
					"store": false,
					"index": "no"
				},
				"image_url5": {
					"type": "String",
					"store": false,
					"index": "no"
				},
				"content_modify_date": {
					"type": "String",
					"store": false,
					"index": "no"
				},
				"package_name": {
					"type": "String",
					"store": false,
					"index": "no"
				},
				"permissions": {
					"type": "String",
					"store": false,
					"index": "no"
				},
				"create_date": {
					"type": "String",
					"store": false,
					"index": "no"
				},
				"modify_date": {
					"type": "String",
					"store": false,
					"index": "no"
				},
				"type_id": {
					"type": "Integer",
					"store": false,
					"index": "not_analyzed",
					"include_in_all": true,
					"indexAnalyzer": "ik_smart", 
					"searchAnalyzer": "ik_smart"
				},
				"packable": {
					"type": "Integer",
					"store": false,
					"index": "not_analyzed",
					"include_in_all": true,
					"indexAnalyzer": "ik_smart", 
					"searchAnalyzer": "ik_smart"
				},
				"status": {
					"type": "Integer",
					"store": false,
					"index": "not_analyzed",
					"include_in_all": true,
					"indexAnalyzer": "ik_smart", 
					"searchAnalyzer": "ik_smart"
				},
				"cpname": {
					"type": "String",
					"store": false,
					"index": "no"
				},
				"channel_id": {
					"type": "Integer",
					"store": false,
					"index": "not_analyzed",
					"include_in_all": true,
					"indexAnalyzer": "ik_smart", 
					"searchAnalyzer": "ik_smart"
				}
			}
		}
	}
}'

现在es创建索引是会自动将refresh周期设为-1，创建完后身为默认值1s，索引索引完毕后要改：
curl -XPUT localhost:9200/crm/_settings -d '{
    "index" : {
        "refresh_interval" : "300s"
    } 
}'

索引与数据库表映射修改：
curl -XPUT 'http://localhost:9200/crm/_mapping/crm_strategy' -d '
{
    "crm_strategy": {
	    "_all":{"enabled":true},
        "properties": {
            "id": {
                "type": "string",
                "store": "yes"
            },
            "strategy_id": {
                "type": "string",
                "store": "yes"
            },
            "login_name": {
                "type": "string",
                "store": "yes"
            }
        }
    }
}'

索引settings修改：
curl -XPUT 'localhost:9200/crm/_settings' -d '
{
    "index" : {
        "number_of_replicas" : 4
    }
}'
 
 
 13、索引优化：
curl -XPUT 'http://localhost:9200/crm/_optimize? max_num_segments =1'
指定index.query.default_field，当_all查询被禁用时

我们强烈建议不要使用字段级别索引期间提升的原因如下：
将此提升和字段长度归约存储在一个字节中意味着字段长度归约会损失精度。结果是ES不能区分一个含有三个单词的字段和一个含有五个单词的字段。
为了修改索引期间提升，你不得不对所有文档重索引。而查询期间的提升则可以因查询而异。
如果一个使用了索引期间提升的字段是多值字段(Multivalue Field)，那么提升值会为每一个值进行乘法操作，导致该字段的权重飙升。


14、删除索引：
curl -XDELETE 'http://localhost:9200/crm'
删除数据：
curl -X DELETE http://localhost:9200/kiwi/ksay/1
curl -XDELETE 'localhost:9200/customer/external/_query?pretty&q=*'


15、mysql同步数据连接：
游戏攻略同步：
curl -XPUT 'http://localhost:9200/_river/crm_jdbc_river/_meta' -d '{
    "type" : "jdbc",
    "jdbc" : {
        "url" : "jdbc:mysql://10.10.1.115:4052/crm?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull",
        "user" : "pubDbUser",
        "password" : "mGame1Spec",
        "sql" : "select `id` as '_id',`id` as 'id',`strategy_id` as 'strategy_id',`game_id` as 'game_id',`game_name` as 'game_name',`app_id` as 'app_id',`title` as 'title',`icon` as 'icon',DATE_FORMAT(`strategy_time`, '%Y-%m-%d %T') as 'strategy_time',`author` as 'author',`sort_id` as 'sort_id',`sort_name` as 'sort_name',`content` as 'content',`is_recommend` as 'is_recommend',`is_allow_comment` as 'is_allow_comment',`data_from` as 'data_from',`status` as 'status',DATE_FORMAT(`add_time`, '%Y-%m-%d %T') as 'add_time' from crm_strategy where app_id > 0",
		"index" : "crm",
		"type" : "crm_strategy",
		"interval" : "3600"
    }
}'
测试：
curl -XGET 'localhost:9200/crm/_search?pretty&q=*'

游戏外放搜索同步：
curl -XPUT 'http://localhost:9200/_river/game_jdbc_river/_meta' -d '{
    "type" : "jdbc",
    "jdbc" : {
        "url" : "jdbc:mysql://10.10.1.115:4051/game_oem2?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull",
        "user" : "pubDbUser",
        "password" : "mGame1Spec",
        "sql" : "select CONCAT(gc.`channel_id`,og.`cid`) as '_id',og.`cid` as 'cid',og.`appid` as 'appid',og.`name` as 'name',og.`size` as 'size',og.`version` as 'version',og.`icon` as 'icon',og.`desc` as 'desc',og.`type` as 'type',og.`level` as 'level',og.`image_url1` as 'image_url1',og.`image_url2` as 'image_url2',og.`image_url3` as 'image_url3',og.`image_url4` as 'image_url4',og.`image_url5` as 'image_url5',DATE_FORMAT(og.`content_modify_date`, '%Y-%m-%d %T') as 'content_modify_date',og.`package_name` as 'package_name',og.`permissions` as 'permissions',DATE_FORMAT(og.`create_date`, '%Y-%m-%d %T') as 'create_date',DATE_FORMAT(og.`modify_date`, '%Y-%m-%d %T') as 'modify_date',og.`type_id` as 'type_id',og.`packable` as 'packable',og.`status` as 'status',og.`cpname` as 'cpname',gc.`channel_id` as 'channel_id' from oem_api_games og inner join (select channel_id,game_id from game_oem2.oem_game_packages where status=2 and channel_id in (select channel_id from MCP.oem_api_channellist)) gc on og.`cid` = gc.`game_id` order by gc.`channel_id`",
		"index" : "game",
		"type" : "game_search",
		"schedule" : "0 0 7 * * ?"
    }
}'
测试：
curl -XGET 'localhost:9200/game/_search?pretty&q=*'

增量更新，表需要维护时间戳，发现时间戳更新的列需要更新
curl -XPUT 'http://localhost:9200/_river/who_jdbc_river/_meta' -d '{
    "type": "jdbc",
    "jdbc": {
        "driver": "com.mysql.jdbc.Driver",
        "url": "jdbc:mysql://localhost:3306/profile",
        "user": "root",
        "password": "root",
        "sql": [
            {
                "statement": "select id as _id,name,login_name from user where mytimestamp > ?",
                "parameter": [
                    "$river.state.last_active_begin"
                ]
            }
        ],
        "index": "profile",
        "type": "user",
        "bulk_size": 100,
        "max_bulk_requests": 30,
        "bulk_timeout": "10s",
        "flush_interval": "5s",
        "schedule": "0 0-59 0-23 ? * *"
    }
}'

删除：
curl -XDELETE 'localhost:9200/_river/game_jdbc_river'


16、手动插入数据：
curl -XPUT 'http://localhost:9200/crm/crm_strategy/1' -d '{ 
    "id" : "1", 
    "app_id" : "4110", 
    "title" : "我是中国人" 
	"content" : "大都嗷嗷发发哦风我发哦范文芳"
}'


17、查询语句模板:
游戏攻略：
{
	"query": {
		"bool": {
			"must": [],
			"must_not": [],
			"should": [{
				"match": {
					"crm_strategy.title": {
						"query": "战记",
						"boost": "10"
					}
				}
			},
			{
				"match": {
					"crm_strategy.content": {
						"query": "战记",
						"boost": "1"
					}
				}
			}]
		}
	},
	"filter": {
		"and": [{
			"term": {
				"app_id": "67344"
			}
		}]
	},
	"highlight": {
		"pre_tags": ["<em>"],
		"post_tags": ["</em>"],
		"fields": {
			"title": {
				
			}
		}
	},
	"from": 0,
	"size": 50
}

游戏外放搜索：
{
	"query": {
		"bool": {
			"must": [],
			"must_not": [],
			"should": [{
				"match": {
					"game_search.name": {
						"query": "战记",
						"boost": "20"
					}
				}
			},
			{
				"match": {
					"game_search.type": {
						"query": "战记",
						"boost": "5"
					}
				}
			},
			{
				"match": {
					"game_search.desc": {
						"query": "战记",
						"boost": "1"
					}
				}
			}]
		}
	},
	"filter": {
		"and": [{
			"term": {
				"status": "1"
			}
		},
		{
			"term": {
				"type_id": "1"
			}
		}]
	},
	"from": 0,
	"size": 50
}


18、mysql数据过滤：
游戏攻略：
select id as 'id',strategy_id as 'strategy_id',game_id as 'game_id',game_name as 'game_name',app_id as 'app_id',
       title as 'title',icon as 'icon',DATE_FORMAT(strategy_time, '%Y-%m-%d %T') as 'strategy_time',author as 'author',
       sort_id as 'sort_id',sort_name as 'sort_name',content as 'content',is_recommend as 'is_recommend',is_allow_comment as 'is_allow_comment',
       data_from as 'data_from',status as 'status',DATE_FORMAT(add_time, '%Y-%m-%d %T') as 'add_time'
from crm_strategy where app_id > 0;

游戏搜索外放：
select og.`id` as '_id',og.`id` as 'cid',og.`app_id` as 'appid',og.`name` as 'name',og.`category` as 'type',
       og.`size` as 'size',og.`version` as 'version',concat('http://img.m.duoku.com/preview/',og.`icon`) as 'iconUrl',
       gb.`game_desc` as 'desc',me.`star` as 'level',og.`sdk_type` as 'sdk_type',gb.`type_id` as 'type_id' 
from game_oem.oem_game og 
inner join gamedev.pt_game_basic_info gb on og.`app_id` = gb.`app_id` 
inner join MCP.mcp_content_game_ext me on og.`id` = me.`c_id` 
inner join MCP.mcp_content_data md on og.`id` = md.`c_id` 
where og.`status` = 0 and og.`size` > 0 and me.`star` >= 0 and gb.`type_id` in(1) and (md.`path_url` like '%_oem_%' or md.`path_url` like '%_DuoKu.apk') 
group by og.`id`


19、搜索返回结果实例：
游戏攻略：
{
	"took": 16,
	"timed_out": false,
	"_shards": {
		"total": 1,
		"successful": 1,
		"failed": 0
	},
	"hits": {
		"total": 144,
		"max_score": 2.2496498,
		"hits": [{
			"_index": "crm",
			"_type": "crm_strategy",
			"_id": "AVEwK8wdUrH-mnY3jbWj",
			"_score": 2.2496498,
			"_source": {
				"author": "集落",
				"icon": "http://img.18183.duoku.com/uploads/allimg/150430/49_043010411493G.jpg",
				"sort_name": "游戏新闻",
				"title": "《这才是三国》今日首曝 三国史诗级大作",
				"data_from": 0,
				"sort_id": 90,
				"game_name": "这才是三国",
				"strategy_time": "2015-04-30T19:37:55.000+08:00",
				"is_allow_comment": 1,
				"is_recommend": -1,
				"strategy_id": 313880,
				"id": 1930423,
				"app_id": 292225,
				"add_time": "2015-11-20T17:51:42.000+08:00",
				"game_id": 292225,
				"status": 0
			},
			"highlight": {
				"title": ["《这才是<em>三国</em>》今日首曝 <em>三国</em>史诗级大作"]
			}
		},
		{
			"_index": "crm",
			"_type": "crm_strategy",
			"_id": "AVEwK8wdUrH-mnY3jbY2",
			"_score": 2.243115,
			"_source": {
				"author": "湿透的胖次",
				"icon": "http://img.18183.duoku.com/uploads/allimg/140731/57_0I109511HT0.jpg",
				"sort_name": "游戏新闻",
				"title": "乱世姐妹大闹三国《媚三国》燃起粉红战役",
				"data_from": 0,
				"sort_id": 90,
				"game_name": "媚三国",
				"strategy_time": "2014-07-31T09:43:46.000+08:00",
				"is_allow_comment": 1,
				"is_recommend": -1,
				"strategy_id": 151648,
				"id": 1930705,
				"app_id": 72138,
				"add_time": "2015-11-20T17:52:32.000+08:00",
				"game_id": 72138,
				"status": 0
			},
			"highlight": {
				"title": ["乱世姐妹大闹<em>三国</em>《媚<em>三国</em>》燃起粉红战役"]
			}
		}]
	}
}

游戏搜索外放：
{
	"took": 7,
	"timed_out": false,
	"_shards": {
		"total": 1,
		"successful": 1,
		"failed": 0
	},
	"hits": {
		"total": 27,
		"max_score": 2.5303993,
		"hits": [{
			"_index": "game",
			"_type": "game_search",
			"_id": "AVE36o2dUrH-mnY3k_4C",
			"_score": 2.5303993,
			"_source": {
				"cid": 59449,
				"appid": 1452,
				"name": "女神战记",
				"type": "网络游戏",
				"size": 40162013,
				"version": "3.0",
				"iconUrl": "http://img.m.duoku.com/preview/wap/59000/59449/xq_1.png",
				"desc": "天降女神，相携杀敌！绚丽技能，激情绽放！夏娃，海伦，盖亚……",
				"level": 4
			}
		},
		{
			"_index": "game",
			"_type": "game_search",
			"_id": "AVE36o2dUrH-mnY3lAAR",
			"_score": 2.5252254,
			"_source": {
				"cid": 67704,
				"appid": 3053997,
				"name": "封神战记",
				"type": "网络游戏",
				"size": 59681906,
				"version": "1.1",
				"iconUrl": "http://img.m.duoku.com/preview/wap/67000/67704/xq_1.png",
				"desc": "《封神战记》魔幻封神榜，携东来紫气三万里......",
				"level": 3
			}
		}]
	}
}


20、概念：
cluster 
　　代表一个集群，集群中有多个节点，其中有一个为主节点，这个主节点是可以通过选举产生的，主从节点是对于集群内部来说的。
es的一个概念就是去中心化，字面上理解就是无中心节点，这是对于集群外部来说的，因为从外部来看es集群，在逻辑上是个整体，你与任何一个节点的通信和与整个es集群通信是等价的。

node
	每台服务器为一个节点，是搜索请求访问es集群的基本单位和入口，一个集群可以有一个或多个节点，其中一个为主节点，处理数据同步、一致性、集群管理等任务，但是对于外部请求
各个节点是对等的，即使是写操作，在主分片上执行，但是不一定在主节点上（与传统集群区别）。

shards 
　　代表索引分片，是一个Lucene实例，es可以把一个完整的索引分成多个分片（类似分库概念），这样的好处是可以把一个大的索引拆分成多个，分布到不同的节点上。
构成分布式搜索。分片的数量只能在索引创建前指定，并且索引创建后不能更改。搜索的时候也需要查询所有这些分片，确保没有数据遗漏。 
 
replicas 
　　代表索引副本，es可以设置多个索引的副本，副本的作用一是提高系统的容错性，当个某个节点某个分片损坏或丢失时可以从副本中恢复。
二是提高es的查询效率，es会自动对搜索请求进行负载均衡。（同一个节点上，一个主分片和它所有副本，只能存在一个） 

index
	索引，类似于mysql中的库（表空间），一个集群可以有多个索引。一个索引实际上只是一个"逻辑命名空间"，用来指向一个或者多个物理地址。
将基础数据切词，这些最小的文字单元使用便于检索的特定数据结构（如B树）存储，这样查询一个词语就像翻字典一样从第一个字母到
最后一个字母依次寻找，最终匹配到一组位置信息，这组位置信息就指向了磁盘中该关键字对应的一组文档。

type
	类型，由index的mapping指定，一个索引可以有多个类型，类似于mysql一个库中的表。多索引、多类型是多租户的实现基础，指定了索引中字段与数据库中字段的映射关系和索引策略等。
	
routing
	routing就是将文档hash到一个特点的primary shard中去，从而避免在primary shards中挨个查找（增删改操作），加快定位速度。
默认是使用文档的_id来hash，保证hash分布均匀。当然查询操作比较复杂需要在所有分片或分片副本中查找再合并。
 
recovery 
　　代表数据恢复或叫数据重新分布，es在有节点加入或退出时会根据机器的负载对索引分片进行重新分配，挂掉的节点重新启动时也会进行数据恢复。 
 
river 
　　代表es的一个数据源，也是其它存储方式（如：数据库）同步数据到es的一个方法。
它是以插件方式存在的一个es服务，通过读取river中的数据并把它索引到es中，官方的river有couchDB的，RabbitMQ的，Twitter的，Wikipedia的。 
 
gateway 
　　代表es索引快照的存储方式，es默认是先把索引存放到内存中，当内存满了时再持久化到本地硬盘。
gateway对索引快照进行存储，当这个es集群关闭再重新启动时就会从gateway中读取索引备份数据。
es支持多种类型的gateway，有本地文件系统（默认），分布式文件系统，Hadoop的HDFS和amazon的s3云存储服务。 
 
discovery.zen 
　　代表es的自动发现节点机制（基于tcp，9300端口），es是一个基于p2p的系统，它先通过广播寻找存在的节点，再通过多播协议来进行节点之间的通信，同时也支持点对点的交互。 
 
Transport 
　　代表es内部节点或集群与客户端的交互方式，默认内部是使用tcp协议进行交互，同时它支持http协议（json格式）、thrift、servlet、memcached、zeroMQ等的传输协议（通过插件方式集成）。

多租户:
	ES的多租户简单的说就是通过多索引多类型机制同时提供给多种业务使用，每种业务使用一个索引（类型）。我们可以把索引理解为关系型数据库里的库，类型为表，那多索引可以理解为
一个数据库系统建立多个库给不同的业务使用。实现es集群复用、业务间数据隔离。

RESTful API：
	一种软件架构风格，web交互方案之一（RESTful、SOAP、XML-rpc）客户端和服务器之间的交互在请求之间是无状态的。从客户端到服务器的每个请求都必须包含理解请求所必需的信息。
灵活、易扩展、跨语言、跨系统。客户端和服务器之间的交互在请求之间是无状态的。从客户端到服务器的每个请求都必须包含理解请求所必需的信息。在REST中，每一个对象都是通过URL来表示的，
对象用户负责将状态信息打包进每一条消息内，以便对象的处理总是无状态的。企业对正规的（基于SOAP）SOA最大的反对声之一便是，这种等级的发现和绑定灵活性不足以适应复杂性。

source field 源字段
	默认情况下，在获取和搜索请求返回值中的 _source 字段保存了源 JSON 文本，这使得我们可以直接在返回结果中访问源数据，而不需要根据 id 再发一次检索请求。
注意：索引的 JSON 字符串将完整返回，无论是否是一个合法的 JSON。该字段的内容也不会描述数据如何被索引。


21、业内应用：
Github：“Github使用Elasticsearch搜索20TB的数据，包括13亿的文件和1300亿行的代码”
维基百科：使用Elasticsearch来进行全文搜做并高亮显示关键词，以及提供search-as-you-type、did-you-mean等搜索建议功能。
英国卫报：使用Elasticsearch来处理访客日志，以便能将公众对不同文章的反应实时地反馈给各位编辑。
Mozilla：Mozilla公司以火狐著名，它目前使用 WarOnOrange 这个项目来进行单元或功能测试，测试的结果以 json的方式索引到elasticsearch中，开发人员可以非常方便的查找 bug。
Sony：Sony公司使用elasticsearch 作为信息搜索引擎
Foursquare：”实时搜索5千万地点信息？Foursquare每天都用Elasticsearch做这样的事“
SoundCloud：“SoundCloud使用Elasticsearch来为1.8亿用户提供即时精准的音乐搜索服务”
Fog Creek：“Elasticsearch使Fog Creek可以在400亿行代码中进行一个月3千万次的查询“
StumbleUpon：”Elasticsearch是StumbleUpon的关键部件，它每天为社区提供百万次的推荐服务“
Infochimps：“在 Infochimps，我们已经索引了25亿文档，总共占用 4TB的空间”。


22、性能数据：
官方推荐配置：
RAM64G、8cores、SSD disk
硬件环境：
三台服务器集群、cpu：POWER7 4228MHz*12、memory：24G、swap:1G、disk：IBMsas 600G、system：Red Hat Enterprise Linux Server 6.4
软件环境：
3主分片、1副本分片、2.4亿条记录、JVM 8g内存
建立索引：
13500条每秒（关闭副本分片）、7700条每秒（打开副本分片）；建立索引期间关闭副本分片，设置index refresh周期-1，获得最佳效率，建立索引完毕再打开。
磁盘占用：
1亿条数据约占用80G磁盘，由于es冗余存储（1副本分片），实际占用160G左右。不要设置过多副本分片。
搜索并发循环压测：
            总数    AVG     50%  90%    MIN  MAX          ERROR比例               QPS               吞吐量kb/s
  1并发：    5088	22	     21	  23	19	  79	0.0	                     44.508984026453454	1242.7093203123634
 10并发：	10322	55	     32	  60	1	9063	0.000775043596202286	179.27920104211898	5001.931108879722
 50并发：	10414	263	     55	 724	0	45724	0.004801229114653352	189.40399759925793	5264.25309158058
100并发：   10994	514	     79	1223	2	40141	0.008822994360560306	193.95928160615364	5370.134106175682
150并发：	10493	769	    243	1682	2	53840	0.014199942819022206	194.16379852707152	5348.106547193618
200并发：   10609	1011	482	2028	4	53794	0.018757658591761713	196.8420662015734	5398.2903162166485
250并发：	10384	1259	509	2452	6	52469	0.024075500770416026	197.32816449081201	5383.704142408025
300并发：   10542	1499	528	2777	3	53004	0.028457598178713718	198.64330130016958	5396.441223708074
350并发：	10717	1749	592	3596	7	53735	0.03237846412242232	    198.18770226537217	5363.334200184928
400并发：   13030	2006	696	3827	6	65788	0.030775134305448964	197.70882330627418	5359.0979529009555


23、相关性排序因子：
ElasticSearch的相似度算法被定义为 TF/IDF，即检索词频率/反向文档频率，包括以下内容：
检索词频率:
检索词在该字段出现的频率？出现频率越高，相关性也越高。 字段中出现过5次要比只出现过1次的相关性高。
反向文档频率:
每个检索词在索引中出现的频率？频率越高，相关性越低。 检索词出现在多数文档中会比出现在少数文档中的权重更低，即检验一个检索词在文档中的普遍重要性。
字段长度准则:
字段的长度是多少？长度越长，相关性越低。检索词出现在一个短的title域要比同样的词出现在一个长的content域相关性更高。
boots查询时人工干预：
通过设置boots值人工干预某个查询语句得分提升（>1）或减弱（<1），从而影响该字段匹配关键字后的得分。
Index建立时指定某字段权重：
和boots类似的效果，但是强烈不建议使用，因为会造成词频评分无效（出现1次和5此得分一样）。
符合查询评分：
如果多条查询子句被合并为一条复合查询语句，比如 bool 查询，则每个查询子句计算得出的评分会被合并到总的相关性评分中。


24、建立索引、搜索过程：
见流程图（PDF查询阶段、网页索引建立）。


25、未来扩展：
像百度一样搜索：nutch爬虫、搜索联想词、相关词搜索、关键词热度影响权重


26、相关资料：
https://www.elastic.co/
https://github.com/jprante/elasticsearch-jdbc
https://github.com/mobz/elasticsearch-head
https://github.com/medcl/elasticsearch-analysis-ik




