package main

import (
	"flag"
	"fmt"

	{{.imports}}

	"github.com/zeromicro/go-zero/zrpc"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

var configFile = flag.String("f", "etc/{{.serviceName}}.yaml", "the config file")

func main() {
	flag.Parse()

	var c config.Config
	//conf.MustLoad(*configFile, &c)
	loadConfig := nacosConfig.MustLoad(*configFile, &c)
	ctx := svc.NewServiceContext(c)

	s := zrpc.MustNewServer(c.RpcServerConf, func(grpcServer *grpc.Server) {
{{range .serviceNames}}       {{.Pkg}}.Register{{.Service}}Server(grpcServer, {{.ServerPkg}}.New{{.Service}}Server(ctx))
{{end}}
		//if c.Mode == service.DevMode || c.Mode == service.TestMode {
			reflection.Register(grpcServer)
		//}
	})

	//rpc log,grpc的全局拦截器
	s.AddUnaryInterceptors(rpcserver.LoggerInterceptor)

	defer s.Stop()

	// 注册服务
	nacosConfig.MustRegister(loadConfig, &c.RpcServerConf)

	fmt.Printf("Starting rpc server at %s...\n", c.ListenOn)
	s.Start()
}
