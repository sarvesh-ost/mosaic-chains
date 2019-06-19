import * as fs from 'fs-extra';

/**
 * Provides file system related operations.
 */
export default class FileSystem {

  /**
   * Checks if path exists on disk (in sync).
   * @param {string} path
   * @return {boolean}
   */
  public static pathExistsSync(path: string): boolean{
    return fs.pathExistsSync(path);
  }

  /**
   * Ensures (in sync) that this path exists on disk (if it doesn't it is created).
   * @param {string} path
   * @return {boolean}
   */
  public static ensureDirSync(path: string){
    return fs.ensureDirSync(path);
  }

  /**
   * Copies (in sync) contents from source to destination.
   * @param {string} source
   * @param {string} destination
   */
  public static copySync(source: string, destination: string){
    return fs.copySync(source, destination);
  }

  /**
   * Removes (in sync) contents on a path from disk.
   * @param {string} source
   */
  public static removeSync(source: string){
    return fs.removeSync(source);
  }

  /**
   * Reads (in sync) file content from disk.
   * @param path
   * @return {Buffer}
   */
  public static readFileSync(path: string): Buffer{
    return fs.readFileSync(path);
  }

  /**
   * Writes (in sync) content to file at given path on disk.
   * @param {string} path
   * @param {Buffer} content
   */
  public static writeFileSync(path: string, content: Buffer){
    return fs.writeFileSync(path, content);
  }

}