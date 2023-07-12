/*
 * @Author: imwyf 1185095602@qq.com
 * @Date: 2023-07-12 21:02:07
 * @LastEditors: imwyf 1185095602@qq.com
 * @LastEditTime: 2023-07-12 21:06:55
 * @FilePath: /imwyf/6.828/lab/lib/exit.c
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */

#include <inc/lib.h>

void exit(void)
{
	// close_all();
	sys_env_destroy(0);
}
