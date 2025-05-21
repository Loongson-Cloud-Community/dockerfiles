src: clean
	wget http://cloud.loongnix.cn/releases/loongarch64abi1/ollama/ollama/0.5.13-OPTIMIZER/ollama
	#       修改了llm部分 增加核心数 提高运行速度的特定版本
#	wget http://cloud.loongnix.cn/releases/loongarch64abi1/ollama/ollama/0.5.13/ollama/ollama && chmod 755 ollama
	git clone --depth 1 -b 0.5.13-loongarch64 https://github.com/Loongson-Cloud-Community/ollama src	
image: src
	cd src && cp ../ollama ./ && docker build -t cr.loongnix.cn/ollama/ollama:0.5.13 -f Dockerfile.loong64 .
push:
	docker push cr.loongnix.cn/ollama/ollama:0.5.13


clean:
	rm -rf ollama src

